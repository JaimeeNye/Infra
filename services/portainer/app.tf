terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "portainer" {
  name = "portainer/portainer-ce:2.19.3" # renovate_docker
}

resource "docker_image" "portainer" {
  name          = "${data.docker_registry_image.portainer.name}@${data.docker_registry_image.portainer.sha256_digest}"
  pull_triggers = [data.docker_registry_image.portainer.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "portainer" {
  image = docker_image.portainer.image_id
  name  = "portainer"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.portainer.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.portainer.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.portainer.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.portainer.tls.certresolver"
    value = "letsencrypt"
  }
  labels {
    label = "traefik.http.services.portainer.loadbalancer.server.port"
    value = "9000"
  }
  networks_advanced {
    name = var.gateway
  }

  command = [
    "-H",
    "unix:///var/run/docker.sock",
    "--admin-password",
    "${var.hashed_admin_password}"
  ]

  volumes {
    volume_name    = docker_volume.portainer_data.name
    container_path = "/data"
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  privileged = true

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "portainer_data" {
  name   = "portainer_data"
  driver = "local"
}
