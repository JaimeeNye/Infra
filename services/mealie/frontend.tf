terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "mealie_frontend" {
  name = "hkotel/mealie:frontend-v1.0.0beta-5" # renovate_docker
}

resource "docker_image" "mealie_frontend" {
  name          = "${data.docker_registry_image.mealie_frontend.name}@${data.docker_registry_image.mealie_frontend.sha256_digest}"
  pull_triggers = [data.docker_registry_image.mealie_frontend.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "mealie_frontend" {
  image = docker_image.mealie_frontend.image_id
  name  = "mealie_frontend"

  env = [
    "ALLOW_SIGNUP=false",
    "API_URL=http://${docker_container.mealie_backend.name}:9000"
  ]
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.mealie_frontend.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.mealie_frontend.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.mealie_frontend.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.mealie_frontend.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    container_path = "/app/data/"
    volume_name    = docker_volume.mealie.name
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "mealie" {
  name   = "mealie_data"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
