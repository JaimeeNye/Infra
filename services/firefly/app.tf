terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}

data "docker_registry_image" "firefly" {
  name = "fireflyiii/core:version-6.0.30" # renovate_docker
}

resource "docker_image" "firefly" {
  name          = "${data.docker_registry_image.firefly.name}@${data.docker_registry_image.firefly.sha256_digest}"
  pull_triggers = [data.docker_registry_image.firefly.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "firefly" {
  image = docker_image.firefly.image_id
  name  = "firefly"

  env = [
    "APP_ENV=production",
    "APP_DEBUG=false",
    "SITE_OWNER=corentin0pape@gmail.com",
    "APP_KEY=${random_password.firefly_app_key.result}",
    "DEFAULT_LANGUAGE=fr_FR",
    "DEFAULT_LOCALE=equal",
    "TZ=Europe/Paris",
    "TRUSTED_PROXIES=**",
    "LOG_CHANNEL=stack",
    "APP_LOG_LEVEL=notice",
    "AUDIT_LOG_LEVEL=emergency",

    "DB_CONNECTION=mysql",
    "DB_HOST=${docker_container.firefly_db.name}",
    "DB_PORT=3306",
    "DB_DATABASE=firefly",
    "DB_USERNAME=firefly",
    "DB_PASSWORD=${random_password.firefly_db.result}",

    "MYSQL_USE_SSL=false",
    "CACHE_DRIVER=file",
    "SESSION_DRIVER=file",
    "COOKIE_PATH=\"/\"",
    "COOKIE_DOMAIN=${var.domain.name}",
    "COOKIE_SECURE=false",
    "COOKIE_SAMESITE=lax",
    "SEND_ERROR_MESSAGE=true",
    "SEND_REPORT_JOURNALS=true",
    "ENABLE_EXTERNAL_RATES=false",
    "AUTHENTICATION_GUARD=web",
    "DISABLE_FRAME_HEADER=false",
    "DISABLE_CSP_HEADER=false",
    "ALLOW_WEBHOOKS=false",
    "DKR_BUILD_LOCALE=false",
    "DKR_CHECK_SQLITE=true",
    "DKR_RUN_MIGRATION=true",
    "DKR_RUN_UPGRADE=true",
    "DKR_RUN_VERIFY=true",
    "DKR_RUN_REPORT=true",
    "DKR_RUN_PASSPORT_INSTALL=true",
    "APP_NAME=FireflyIII",
    "BROADCAST_DRIVER=log",
    "QUEUE_DRIVER=sync",
    "CACHE_PREFIX=firefly",
    "FIREFLY_III_LAYOUT=v1",
    "STATIC_CRON_TOKEN=${random_password.firefly_cron_token.result}",
    "APP_URL=https://${var.subdomain}.${var.domain.name}"
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
    label = "traefik.http.routers.firefly.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.firefly.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.firefly.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.firefly.tls.certresolver"
    value = "letsencrypt"
  }
  networks_advanced {
    name = var.gateway
  }

  volumes {
    container_path = "/var/www/html/storage/upload"
    host_path      = "/mnt/raid/firefly_data/firefly"
  }

  log_driver = "json-file"
  log_opts = {
    max-size : "15m"
    max-file : 3
  }

  destroy_grace_seconds = 60

  restart = "unless-stopped"
}

resource "random_password" "firefly_app_key" {
  length  = 32
  special = false
  lifecycle {
    prevent_destroy = true
  }
}
