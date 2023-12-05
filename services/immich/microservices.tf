data "docker_registry_image" "immich_microservices" {
  name = "ghcr.io/immich-app/immich-server:${local.version}"
}

resource "docker_image" "immich_microservices" {
  name          = "${data.docker_registry_image.immich_microservices.name}@${data.docker_registry_image.immich_microservices.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_microservices.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_microservices" {
  image = docker_image.immich_microservices.image_id
  name  = "immich-microservices"

  env = [
    "TYPESENSE_API_KEY=${random_password.typesense_api_key.result}",
    "MYSQL_DATABASE=owncloud",
    "MYSQL_USER=owncloud",
    "DB_PASSWORD=${random_password.immich_db.result}",
    "DB_HOSTNAME=immich-postgres",
    "DB_USERNAME=postgres",
    "DB_DATABASE_NAME=immich",
    "REDIS_HOSTNAME=immich_redis"
  ]
  command = ["start.sh", "microservices"]

  volumes {
    container_path = "/usr/src/app/upload"
    host_path      = "/mnt/raid/immich_data/upload"
  }
  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
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
