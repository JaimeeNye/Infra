data "docker_registry_image" "firefly_importer" {
  name = "fireflyiii/data-importer:version-1.3.8" # renovate_docker
}

resource "docker_image" "firefly_importer" {
  name          = "${data.docker_registry_image.firefly_importer.name}@${data.docker_registry_image.firefly_importer.sha256_digest}"
  pull_triggers = [data.docker_registry_image.firefly_importer.sha256_digest]
}

resource "docker_container" "firefly_importer" {
  image = docker_image.firefly_importer.image_id
  name  = "firefly_importer_${sha256(data.docker_registry_image.firefly_importer.sha256_digest)}"

  env = [
    "FIREFLY_III_URL=http://${docker_container.firefly.name}:8080",
    "VANITY_URL=https://${var.subdomain}.${var.domain.name}",
    "USE_CACHE=false",
    "IGNORE_DUPLICATE_ERRORS=false",
    "CAN_POST_AUTOIMPORT=false",
    "CAN_POST_FILES=false",
    "VERIFY_TLS_SECURITY=true",
    "CONNECTION_TIMEOUT=31.41",
    "APP_ENV=production",
    "APP_DEBUG=false",
    "LOG_CHANNEL=stack",
    "LOG_LEVEL=info",
    "TRUSTED_PROXIES=**",
    "TZ=Europe/Paris",
    "EXPECT_SECURE_URL=true",
    "BROADCAST_DRIVER=log",
    "CACHE_DRIVER=file",
    "QUEUE_CONNECTION=sync",
    "SESSION_DRIVER=file",
    "SESSION_LIFETIME=120",
    "IS_EXTERNAL=false",
    "APP_NAME=DataImporter",
    "APP_URL=https://${var.importer_subdomain}.${var.domain.name}"
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
    label = "traefik.http.routers.firefly_importer.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.firefly_importer.rule"
    value = "Host(`${var.importer_subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.firefly_importer.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.firefly_importer.tls.certresolver"
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
