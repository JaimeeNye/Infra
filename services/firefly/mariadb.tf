data "docker_registry_image" "firefly_db" {
  name = "mariadb:11.1.2" # renovate_docker
}

resource "docker_image" "firefly_db" {
  name          = "${data.docker_registry_image.firefly_db.name}@${data.docker_registry_image.firefly_db.sha256_digest}"
  pull_triggers = [data.docker_registry_image.firefly_db.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "firefly_db" {
  image = docker_image.firefly_db.image_id
  name  = "firefly_db"

  env = [
    "MYSQL_RANDOM_ROOT_PASSWORD=\"true\"",
    "MYSQL_DATABASE=firefly",
    "MYSQL_USER=firefly",
    "MYSQL_PASSWORD=${random_password.firefly_db.result}"
  ]

  volumes {
    container_path = "/var/lib/mysql"
    host_path      = "/mnt/raid/firefly_data/firefly_db"
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


resource "random_integer" "firefly_db_password_length" {
  min = 12
  max = 20
  lifecycle {
    prevent_destroy = true
  }
}
resource "random_password" "firefly_db" {
  length  = random_integer.firefly_db_password_length.result
  special = false
  lifecycle {
    prevent_destroy = true
  }
}
