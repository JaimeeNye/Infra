terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "archive_file" "src" {
  type        = "zip"
  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/src.zip"
}

resource "null_resource" "tbeteouquoi_build" {
  triggers = {
    src_hash = "${data.archive_file.src.output_sha}"
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/src"
    environment = {
      MACHINE_NAME = var.machine.name
    }
    command = "./build.sh"
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "docker_registry_image" "tbeteouquoi" {
  name = "infra/tbeteouquoi:latest"
  depends_on = [
    null_resource.tbeteouquoi_build // On this data source bc otherwise the docker provider tries to fetch it and gets a 401 if it does not exist yet
  ]
}

resource "docker_image" "tbeteouquoi" {
  name          = "${data.docker_registry_image.tbeteouquoi.name}@${data.docker_registry_image.tbeteouquoi.sha256_digest}"
  pull_triggers = [data.docker_registry_image.tbeteouquoi.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "tbeteouquoi" {
  image = docker_image.tbeteouquoi.image_id
  name  = "tbeteouquoi_${sha256(data.docker_registry_image.tbeteouquoi.sha256_digest)}"
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.rule"
    value = "Host(`${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.tbeteouquoi.tls.certresolver"
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

  lifecycle {
    create_before_destroy = true
  }
}
