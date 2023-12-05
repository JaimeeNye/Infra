terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "netdata" {
  name = "netdata/netdata:v1.43.2" # renovate_docker
}

resource "docker_image" "netdata" {
  name          = "${data.docker_registry_image.netdata.name}@${data.docker_registry_image.netdata.sha256_digest}"
  pull_triggers = [data.docker_registry_image.netdata.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "netdata" {
  image = docker_image.netdata.image_id
  name  = "netdata_${sha256(data.docker_registry_image.netdata.sha256_digest)}"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.netdata.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.netdata.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.netdata.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.netdata.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.netdata.middlewares"
    value = "sso"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    host_path      = "/etc/passwd"
    container_path = "/host/etc/passwd"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/group"
    container_path = "/host/etc/group"
    read_only      = true
  }
  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  capabilities {
    add = ["SYS_PTRACE"]
  }

  security_opts = ["apparmor:unconfined"]

  upload {
    file           = "/usr/lib/netdata/conf.d/health_alarm_notify.conf"
    content_base64 = local.health_alarm_notify
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"

  lifecycle {
    create_before_destroy = true
  }
}
