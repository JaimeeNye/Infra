data "docker_registry_image" "pihole" {
  name = "pihole/pihole:2023.11.0" # renovate_docker
}

resource "docker_image" "pihole" {
  name          = "${data.docker_registry_image.pihole.name}@${data.docker_registry_image.pihole.sha256_digest}"
  pull_triggers = [data.docker_registry_image.pihole.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "pihole" {
  image = docker_image.pihole.image_id
  name  = "pihole"

  env = [
    "TZ=Europe/Paris",
    "WEBPASSWORD=${var.password}"
  ]

  capabilities {
    add = ["CAP_NET_BIND_SERVICE"]
  }

  ports {
    external = 53
    internal = 53
    protocol = "udp"
  }

  ports {
    external = 53
    internal = 53
    protocol = "tcp"
  }

  ports {
    external = 8081
    internal = 80
  }

  volumes {
    container_path = "/etc/pihole"
    volume_name    = docker_volume.pihole_data.name
  }

  volumes {
    container_path = "/etc/dnsmasq.d"
    volume_name    = docker_volume.dnsmasq.name
  }

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.pihole.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.pihole.rule"
    value = "Host(`${var.pihole_subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.pihole.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.services.pihole.loadbalancer.server.port"
    value = "80"
  }
  labels {
    label = "traefik.http.routers.pihole.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "pihole_data" {
  name   = "pihole_data"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "dnsmasq" {
  name   = "pihole_dnsmasq"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
