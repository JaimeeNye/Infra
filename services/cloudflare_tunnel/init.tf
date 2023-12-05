terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}
