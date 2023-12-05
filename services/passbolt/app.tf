terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "passbolt" {
  name = "passbolt/passbolt:latest-ce"
}

resource "docker_image" "passbolt" {
  name          = "${data.docker_registry_image.passbolt.name}@${data.docker_registry_image.passbolt.sha256_digest}"
  pull_triggers = [data.docker_registry_image.passbolt.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "passbolt" {
  image = docker_image.passbolt.image_id
  name  = "passbolt"
  env = [
    "APP_FULL_BASE_URL=https://${var.subdomain}.${var.domain.name}",
    "DATASOURCES_DEFAULT_HOST=${docker_container.passbolt_db.name}:3306",
    "DATASOURCES_DEFAULT_USERNAME=passbolt",
    "DATASOURCES_DEFAULT_PASSWORD=${random_password.passbolt_db_password.result}",
    "DATASOURCES_DEFAULT_DATABASE=passbolt"
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
    label = "traefik.http.routers.passbolt.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.passbolt.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.passbolt.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.passbolt.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }
  volumes {
    container_path = "/etc/passbolt/gpg"
    volume_name    = docker_volume.passbolt_gpg.name
  }
  volumes {
    container_path = "/etc/passbolt/jwt"
    volume_name    = docker_volume.passbolt_jwt.name
  }
  command = ["/usr/bin/wait-for.sh", "-t", "0", "${docker_container.passbolt_db.name}:3306", "--", "/docker-entrypoint.sh"]

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "docker_volume" "passbolt_gpg" {
  name   = "passbolt_gpg_static"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
resource "docker_volume" "passbolt_jwt" {
  name   = "passbolt_jwt_static"
  driver = "local"

  lifecycle {
    prevent_destroy = true
  }
}
