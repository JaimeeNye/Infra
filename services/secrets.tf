resource "random_password" "sso_salt" {
  length = 8
}
resource "htpasswd_password" "sso" {
  password = var.sso_password
  salt     = random_password.sso_salt.result
}

resource "random_password" "admin_salt" {
  length = 8
}
resource "htpasswd_password" "admin" {
  password = var.admin_password
  salt     = random_password.admin_salt.result
}

resource "random_password" "elasticsearch_salt" {
  length = 8
}
resource "random_password" "elasticsearch" {
  length  = 16
  special = false
}
resource "htpasswd_password" "elasticsearch" {
  password = random_password.elasticsearch.result
  salt     = random_password.elasticsearch_salt.result
}
