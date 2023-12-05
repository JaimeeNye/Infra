data "cloudflare_zone" "infra" {
  name = "infra.com"
}

data "cloudflare_zone" "tbeteouquoi" {
  name = "tbeteouquoi.fr"
}

locals {
  hostnames = [
    {
      "subdomain" = "@",
      "private"   = false,
      "domain"    = data.cloudflare_zone.tbeteouquoi
    },
    {
      "subdomain" = "passbolt",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "cockpit",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "cloud",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "gatus",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "monitoring",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "mealie",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "@",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "home",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "commander",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "share",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "pdf",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "boinc",
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "firefly",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "import.firefly",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "photos",
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "n8n"
      "private"   = false,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "dns"
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    },
    {
      "subdomain" = "wireguard"
      "private"   = true,
      "domain"    = data.cloudflare_zone.infra
    }
  ]

  hostnames_public_map = {
    for index, hostname in local.hostnames :
    "${hostname.subdomain}.${hostname.domain.name}" => hostname
    if hostname.private == false
  }
  hostnames_private_map = {
    for index, hostname in local.hostnames :
    "${hostname.subdomain}.${hostname.domain.name}" => hostname
    if hostname.private
  }
}

resource "cloudflare_record" "services" {
  for_each = local.hostnames_public_map
  zone_id  = each.value.domain.zone_id
  name     = each.value.subdomain
  value    = local.vultr_machine.address
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_record" "private_services" {
  for_each = local.hostnames_private_map
  zone_id  = each.value.domain.zone_id
  name     = each.value.subdomain
  value    = local.homeserver_machine.lan_ip
  type     = "A"
  ttl      = 360
  proxied  = false
}
