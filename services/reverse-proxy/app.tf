terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "reverse-proxy" {
  name = "traefik:2.10.6" # renovate_docker
}

resource "docker_image" "reverse-proxy" {
  name          = "${data.docker_registry_image.reverse-proxy.name}@${data.docker_registry_image.reverse-proxy.sha256_digest}"
  pull_triggers = [data.docker_registry_image.reverse-proxy.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "reverse-proxy" {
  image = docker_image.reverse-proxy.image_id
  name  = "reverse-proxy"

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = docker_network.gateway.name
  }
  labels {
    label = "traefik.http.middlewares.sso.basicauth.users"
    value = "corentin_sso:${var.sso_password_hash}"
  }
  labels {
    label = "traefik.http.middlewares.sso.basicauth.removeheader"
    value = "true"
  }
  labels {
    label = "traefik.http.middlewares.elasticsearch_auth.basicauth.users"
    value = "elastic:${var.elasticsearch_password_hash}"
  }
  labels {
    label = "traefik.http.middlewares.elasticsearch_auth.basicauth.removeheader"
    value = "true"
  }

  dynamic "ports" {
    for_each = var.publish_ports ? [{ "internal" : 80, "external" : 80 }, { "internal" : 443, "external" : 443 }] : []
    content {
      internal = ports.value["internal"]
      external = ports.value["external"]
    }
  }

  env = [
    "CLOUDFLARE_EMAIL=corentin0pape@gmail.com",
    "CLOUDFLARE_API_KEY=${var.cloudflare_global_api_key}"
  ]

  networks_advanced {
    name = docker_network.gateway.name
  }

  upload {
    file        = "/traefik.yml"
    source      = "${path.module}/src/traefik.yml"
    source_hash = filesha256("${path.module}/src/traefik.yml")
  }
  upload {
    file        = "/traefik_config.yml"
    source      = "${path.module}/src/traefik_config.yml"
    source_hash = filesha256("${path.module}/src/traefik_config.yml")
  }

  volumes {
    container_path = "/srv"
    volume_name    = docker_volume.reverse-proxy.name
  }

  volumes {
    container_path = "/var/log/traefik"
    volume_name    = docker_volume.reverse-proxy_logs.name
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "reverse-proxy" {
  name   = "reverse-proxy_static"
  driver = "local"
}

resource "docker_volume" "reverse-proxy_logs" {
  name   = "reverse-proxy_logs"
  driver = "local"
}

resource "docker_network" "gateway" {
  name       = "gateway"
  driver     = "bridge"
  attachable = true
}
