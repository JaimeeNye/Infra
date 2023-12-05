terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "pdf-tools" {
  name = "frooodle/s-pdf:0.15.1" # renovate_docker
}

resource "docker_image" "pdf-tools" {
  name          = "${data.docker_registry_image.pdf-tools.name}@${data.docker_registry_image.pdf-tools.sha256_digest}"
  pull_triggers = [data.docker_registry_image.pdf-tools.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "pdf-tools" {
  image = docker_image.pdf-tools.image_id
  name  = "pdf-tools_${sha256(data.docker_registry_image.pdf-tools.sha256_digest)}"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.pdf-tools.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.routers.pdf-tools.middlewares"
    value = "sso"
  }
  networks_advanced {
    name = var.gateway
  }

  env = [
    "TZ=Europe/Paris",
    "SYSTEM_DEFAULTLOCALE=fr-FR"
  ]

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
