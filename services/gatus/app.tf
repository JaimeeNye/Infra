terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "gatus" {
  name = "twinproduction/gatus:v5.7.0" # renovate_docker
}

resource "docker_image" "gatus" {
  name          = "${data.docker_registry_image.gatus.name}@${data.docker_registry_image.gatus.sha256_digest}"
  pull_triggers = [data.docker_registry_image.gatus.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "gatus" {
  image = docker_image.gatus.image_id
  name  = "gatus"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.gatus.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.gatus.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.gatus.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.gatus.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  upload {
    file = "/config/config.yaml"
    content = templatefile("${path.module}/src/${var.config_path}",
      {
        discord_webhook = var.discord_webhook
      }
    )
  }

  volumes {
    container_path = "/srv/"
    volume_name    = docker_volume.gatus.name
  }

  destroy_grace_seconds = 60

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  restart = "unless-stopped"
}

resource "docker_volume" "gatus" {
  name   = "gatus_static"
  driver = "local"
}
