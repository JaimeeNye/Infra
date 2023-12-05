terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "boinc" {
  name = "linuxserver/boinc:7.20.5" # renovate_docker
}

resource "docker_image" "boinc" {
  name          = "${data.docker_registry_image.boinc.name}@${data.docker_registry_image.boinc.sha256_digest}"
  pull_triggers = [data.docker_registry_image.boinc.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "boinc" {
  image = docker_image.boinc.image_id
  name  = "boinc"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.boinc.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.boinc.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.boinc.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.services.boinc.loadbalancer.server.port"
    value = "8080"
  }
  labels {
    label = "traefik.http.routers.boinc.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.boinc.middlewares"
    value = "sso"
  }
  networks_advanced {
    name = var.gateway
  }

  cpu_shares = 256

  env = [
    "TZ=Europe/Paris"
  ]

  volumes {
    container_path = "/config"
    volume_name    = docker_volume.boinc.name
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "boinc" {
  name   = "boinc_static"
  driver = "local"
}
