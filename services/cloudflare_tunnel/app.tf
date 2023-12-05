data "docker_registry_image" "cloudflared" {
  name = "cloudflare/cloudflared:2023.10.0" # renovate_docker
}

resource "docker_image" "cloudflared" {
  name          = "${data.docker_registry_image.cloudflared.name}@${data.docker_registry_image.cloudflared.sha256_digest}"
  pull_triggers = [data.docker_registry_image.cloudflared.sha256_digest]

  lifecycle {
    create_before_destroy = true
  }
}

resource "docker_container" "cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "cloudflared"

  command = ["tunnel", "--no-autoupdate", "run"]

  env = [
    "TUNNEL_TOKEN=${cloudflare_tunnel.tunnel.tunnel_token}"
  ]

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
