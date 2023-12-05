data "cloudflare_record" "dyndns" {
  zone_id  = var.dyndns_zone.id
  hostname = "homeserver.${var.dyndns_zone.name}"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/ansible/inventory.template.yml",
    {
      dyndns_address = "homeserver.${var.dyndns_zone.name}"
    }
  )
  filename = "${path.module}/ansible/inventory.yml"
}

resource "null_resource" "ansible_configuration" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/ansible/"
    command     = "./ansible_script.sh"
    environment = {
      DYNDNS_SUBDOMAIN = "homeserver"
      DYNDNS_RECORD_ID = data.cloudflare_record.dyndns.id
      DYNDNS_ZONE_ID   = var.dyndns_zone.id
      DYNDNS_TOKEN     = var.dyndns_token
    }
  }
}
