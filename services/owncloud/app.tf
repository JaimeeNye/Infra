terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "owncloud" {
  name = "owncloud/server:10.13" # renovate_docker
}

resource "docker_image" "owncloud" {
  name          = "${data.docker_registry_image.owncloud.name}@${data.docker_registry_image.owncloud.sha256_digest}"
  pull_triggers = [data.docker_registry_image.owncloud.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "owncloud" {
  image = docker_image.owncloud.image_id
  name  = "owncloud"

  env = [
    "OWNCLOUD_DOMAIN=${var.subdomain}.${var.domain.name}",
    "OWNCLOUD_TRUSTED_DOMAINS=${var.subdomain}.${var.domain.name}",
    "OWNCLOUD_ADMIN_USERNAME=${var.owncloud_admin_username}",
    "OWNCLOUD_ADMIN_PASSWORD=${var.owncloud_admin_password}",
    "OWNCLOUD_REDIS_ENABLED=true",
    "OWNCLOUD_REDIS_HOST=${resource.docker_container.redis.name}",
    "OWNCLOUD_DB_TYPE=mysql",
    "OWNCLOUD_DB_NAME=owncloud",
    "OWNCLOUD_DB_USERNAME=owncloud",
    "OWNCLOUD_DB_PASSWORD=${var.owncloud_db_password}",
    "OWNCLOUD_DB_HOST=${docker_container.owncloud_db.name}",
    "OWNCLOUD_MYSQL_UTF8MB4=true",
    "HTTP_PORT=8080"
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
    label = "traefik.http.routers.owncloud.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.owncloud.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.owncloud.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.owncloud.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    container_path = "/mnt/data"
    host_path      = "/mnt/raid/owncloud_data/owncloud"
  }

  healthcheck {
    test     = ["CMD", "/usr/bin/healthcheck"]
    interval = "30s"
    timeout  = "10s"
    retries  = 5
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}
