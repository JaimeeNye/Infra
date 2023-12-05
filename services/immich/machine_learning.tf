data "docker_registry_image" "immich_machine_learning" {
  name = "ghcr.io/immich-app/immich-machine-learning:${local.version}"
}

resource "docker_image" "immich_machine_learning" {
  name          = "${data.docker_registry_image.immich_machine_learning.name}@${data.docker_registry_image.immich_machine_learning.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_machine_learning.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_machine_learning" {
  image = docker_image.immich_machine_learning.image_id
  name  = "immich-machine-learning"

  volumes {
    container_path = "/cache"
    volume_name    = docker_volume.immich_machine_learning_cache.name
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

resource "docker_volume" "immich_machine_learning_cache" {
  name   = "machine_learning_cache"
  driver = "local"
}
