resource "random_id" "tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = random_id.tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.tunnel.id

  config {
    dynamic "ingress_rule" {
      for_each = var.hostnames
      content {
        hostname = ingress_rule.value
        origin_request {
          http2_origin       = true
          origin_server_name = ingress_rule.value
        }
        service = "https://reverse-proxy:443"
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}
