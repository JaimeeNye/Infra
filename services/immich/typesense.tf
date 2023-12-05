data "docker_registry_image" "immich_typesense" {
  name = "typesense/typesense:0.24.1" # renovate_docker
}

resource "docker_image" "immich_typesense" {
  name          = "${data.docker_registry_image.immich_typesense.name}@${data.docker_registry_image.immich_typesense.sha256_digest}"
  pull_triggers = [data.docker_registry_image.immich_typesense.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "immich_typesense" {
  image = docker_image.immich_typesense.image_id
  name  = "typesense"

  env = [
    "TYPESENSE_API_KEY=${random_password.typesense_api_key.result}",
    "TYPESENSE_DATA_DIR=/data",
    # remove this to get debug messages
    "GLOG_minloglevel=1"
  ]
  command = ["--api-key", random_password.typesense_api_key.result, "--data-dir", "/data"]

  volumes {
    container_path = "/data"
    volume_name    = docker_volume.immich_typesense_data.name
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

resource "docker_volume" "immich_typesense_data" {
  name   = "immich_typesense_data"
  driver = "local"
}

resource "random_password" "typesense_api_key" {
  length  = 32
  special = false
  lifecycle {
    prevent_destroy = true
  }
}
