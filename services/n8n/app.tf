terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "n8n" {
  name = "n8nio/n8n:ai-beta" # renovate_docker
}

resource "docker_image" "n8n" {
  name          = "${data.docker_registry_image.n8n.name}@${data.docker_registry_image.n8n.sha256_digest}"
  pull_triggers = [data.docker_registry_image.n8n.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "n8n" {
  image = docker_image.n8n.image_id
  name  = "n8n"

  env = [
    "N8N_HOST=${var.subdomain}.${var.domain.name}",
    "N8N_PORT=5678",
    "N8N_PROTOCOL=https",
    "NODE_ENV=production",
    "WEBHOOK_URL=https://${var.subdomain}.${var.domain.name}/",
    "GENERIC_TIMEZONE=Europe/Paris"
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
    label = "traefik.http.routers.n8n.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.n8n.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.n8n.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.n8n.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    container_path = "/files"
    volume_name    = docker_volume.n8n_local_files.name
  }
  volumes {
    container_path = "/home/node/.n8n"
    volume_name    = docker_volume.n8n_data.name
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "n8n_local_files" {
  name   = "n8n_local_files"
  driver = "local"
  lifecycle {
    prevent_destroy = true
  }
}

resource "docker_volume" "n8n_data" {
  name   = "n8n_data"
  driver = "local"
  lifecycle {
    prevent_destroy = true
  }
}
