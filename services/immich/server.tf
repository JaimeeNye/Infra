data "docker_registry_image" "immich_server" {
  name = "ghcr.io/immich-app/immich-server:${local.version}"
}

resource "docker_image" "immich_server" {
  name          = "${data.docker_registry_image.immich_server.name}@${data.docker_registry_image.immich_server.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_server.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_server" {
  image = docker_image.immich_server.image_id
  name  = "immich-server"

  env = [
    "TYPESENSE_API_KEY=${random_password.typesense_api_key.result}",
    "MYSQL_DATABASE=owncloud",
    "MYSQL_USER=owncloud",
    "DB_PASSWORD=${random_password.immich_db.result}",
    "DB_HOSTNAME=immich-postgres",
    "DB_USERNAME=postgres",
    "DB_DATABASE_NAME=immich",
    "REDIS_HOSTNAME=immich_redis",
    "IMMICH_API_URL_EXTERNAL=https://${var.subdomain}.${var.domain.name}"
  ]

  command = ["start.sh", "immich"]

  volumes {
    container_path = "/usr/src/app/upload"
    host_path      = "/mnt/raid/immich_data/upload"
  }
  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.docker.network"
    value = var.gateway
  }
  labels {
    label = "traefik.http.routers.immich.entryPoints"
    value = "secure"
  }
  labels {
    label = "traefik.http.routers.immich.rule"
    value = "Host(`${var.subdomain}.${var.domain.name}`)"
  }
  labels {
    label = "traefik.http.routers.immich.tls"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.immich.tls.certresolver"
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

  depends_on = [
    docker_container.immich_redis,
    docker_container.immich_db,
    docker_container.immich_typesense
  ]
}
