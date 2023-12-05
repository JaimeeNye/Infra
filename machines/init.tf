terraform {
  backend "s3" {
    bucket         = "infra-terraform-states"
    key            = "infra/machines.tf"
    region         = "eu-west-3"
    dynamodb_table = "infra-terraform-locks"
    encrypt        = true
  }
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.5"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}
