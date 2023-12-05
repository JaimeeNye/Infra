variable "sso_password_hash" {
  sensitive = true
}
variable "elasticsearch_password_hash" {
  sensitive = true
}
variable "cloudflare_global_api_key" {
  sensitive = true
}
variable "cloudflare_account_id" {
  sensitive = true
}
variable "crowdsec_api_key" {
  sensitive = true
}
variable "publish_ports" {
  default = false
}
output "gateway" {
  value = docker_network.gateway.name
}
