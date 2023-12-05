data "docker_registry_image" "firefly_cron" {
  name = "alpine:3.18.5" # renovate_docker
}

resource "docker_image" "firefly_cron" {
  name          = "${data.docker_registry_image.firefly_cron.name}@${data.docker_registry_image.firefly_cron.sha256_digest}"
  pull_triggers = [data.docker_registry_image.firefly_cron.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "firefly_cron" {
  image = docker_image.firefly_cron.image_id
  name  = "firefly_cron"

  env = [
    "TZ=Europe/Paris"
  ]

  command = ["sh", "-c", "echo \"0 3 * * * wget -qO- http://${docker_container.firefly.name}:8080/api/v1/cron/${random_password.firefly_cron_token.result}\" | crontab - && crond -f -L /dev/stdout"]

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

resource "random_password" "firefly_cron_token" {
  length  = 32
  special = false
  lifecycle {
    prevent_destroy = true
  }
}
