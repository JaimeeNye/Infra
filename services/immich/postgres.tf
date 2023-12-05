data "docker_registry_image" "immich_db" {
  name = "postgres:14-alpine" # renovate_docker
}

resource "docker_image" "immich_db" {
  name          = "${data.docker_registry_image.immich_db.name}@${data.docker_registry_image.immich_db.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_db.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_db" {
  image = docker_image.immich_db.image_id
  name  = "immich-postgres"

  env = [
    "POSTGRES_PASSWORD=${random_password.immich_db.result}",
    "POSTGRES_USER=postgres",
    "POSTGRES_DB=immich"
  ]

  volumes {
    container_path = "/var/lib/postgresql/data"
    host_path      = "/mnt/raid/immich_data/immich_db"
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
}

resource "random_integer" "immich_db_password_length" {
  min = 12
  max = 20
}
resource "random_password" "immich_db" {
  length  = random_integer.immich_db_password_length.result
  special = false
}
