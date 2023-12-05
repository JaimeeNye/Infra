data "cloudflare_zone" "dyndns" {
  name = var.dyndns_zone_name
}

resource "cloudflare_record" "vultr_dyndns" {
  zone_id = data.cloudflare_zone.dyndns.zone_id
  name    = "vultr"
  value   = "1.1.1.1"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "homeserver_dyndns" {
  zone_id = data.cloudflare_zone.dyndns.zone_id
  name    = "homeserver"
  value   = "1.1.1.1"
  type    = "A"
  proxied = false
}