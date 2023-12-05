data "docker_registry_image" "immich_redis" {
  name = "redis:6.2-alpine" # renovate_docker
}

resource "docker_image" "immich_redis" {
  name          = "${data.docker_registry_image.immich_redis.name}@${data.docker_registry_image.immich_redis.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_redis.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_redis" {
  image = docker_image.immich_redis.image_id
  name  = "immich_redis"
  networks_advanced {
    name = var.gateway
  }

  healthcheck {
    test     = ["CMD", "redis-cli", "ping"]
    interval = "10s"
    timeout  = "5s"
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
