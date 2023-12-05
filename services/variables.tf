variable "cloudflare_token" {
  sensitive = true
}
variable "cloudflare_global_api_key" {
  sensitive = true
}
variable "cloudflare_account_id" {
  sensitive = true
}
variable "admin_password" {
  sensitive = true
}
variable "owncloud_db_password" {
  sensitive = true
}
variable "rcon_password" {
  sensitive = true
}
variable "gamerpc_mac_address" {
  sensitive = true
}
variable "rwol_password" {
  sensitive = true
}
variable "sso_password" {
  sensitive = true
}
variable "discord_webhook_homeserver" {
  sensitive = true
}
variable "discord_webhook_vultr" {
  sensitive = true
}
variable "discord_webhook_gatus" {
  sensitive = true
}
variable "deploy_workflow_token" {
  sensitive = true
}
variable "dyndns_zone_name" {
  sensitive = true
}
variable "ru19h_token" {
  sensitive = true
}
variable "docker_password" {
  sensitive = true
}
variable "vultr_crowdsec_api_key" {
  sensitive = true
  default   = "undefined"
}
variable "homeserver_crowdsec_api_key" {
  sensitive = true
  default   = "undefined"
}
