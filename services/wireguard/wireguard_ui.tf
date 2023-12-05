terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "wireguard_ui" {
  name = "ngoduykhanh/wireguard-ui:0.5.2" # renovate_docker
}

resource "docker_image" "wireguard_ui" {
  name          = "${data.docker_registry_image.wireguard_ui.name}@${data.docker_registry_image.wireguard_ui.sha256_digest}"
  pull_triggers = [data.docker_registry_image.wireguard_ui.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "wireguard_ui" {
  image = docker_image.wireguard_ui.image_id
  name  = "wireguard_ui"

  env = [
    "PUID=1000",
    "PGID=1000",
    "TZ=Europe/Paris",
    "WGUI_PASSWORD=${var.password}",
    "WGUI_SERVER_INTERFACE_ADDRESSES=10.252.1.0/24",
    "WGUI_DNS=${var.machine.lan_ip}",
    "WGUI_SERVER_POST_UP_SCRIPT=iptables -t nat -A POSTROUTING -s 10.252.1.0/24 -o enp4s0 -j MASQUERADE; iptables -A INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT;",
    "WGUI_SERVER_POST_DOWN_SCRIPT=iptables -t nat -D POSTROUTING -s 10.252.1.0/24 -o enp4s0 -j MASQUERADE; iptables -D INPUT -p udp -m udp --dport 51820 -j ACCEPT; iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT;",
    "WGUI_DEFAULT_CLIENT_ALLOWED_IPS=192.168.1.0/24",
    "WGUI_MTU=1500",
    "WGUI_MANAGE_START=true",
    "WGUI_MANAGE_RESTART=true",
    "WGUI_ENDPOINT_ADDRESS=${var.machine.dyndns_address}"
  ]

  capabilities {
    add = ["NET_ADMIN"]
  }

  volumes {
    container_path = "/etc/wireguard"
    volume_name    = docker_volume.wireguard_data.name
  }

  volumes {
    container_path = "/app/db"
    volume_name    = docker_volume.wireguard_ui_db.name
  }

  network_mode = "host"

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "wireguard_ui_db" {
  name   = "wireguard_ui_db"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "wireguard_data" {
  name   = "wireguard_data"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
