terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "2.17.1"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}
