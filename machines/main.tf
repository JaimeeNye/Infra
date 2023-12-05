module "vultr_machine" {
  source       = "./vultr"
  dyndns_token = var.dyndns_token
  dyndns_zone  = data.cloudflare_zone.dyndns
}

module "homeserver_machine" {
  source       = "./homeserver"
  dyndns_token = var.dyndns_token
  dyndns_zone  = data.cloudflare_zone.dyndns
}
