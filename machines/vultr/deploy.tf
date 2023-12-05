# Configure the Vultr Provider
provider "vultr" {
  rate_limit  = 100
  retry_limit = 3
}

resource "vultr_instance" "vultr_machine" {
  plan        = "vhf-2c-2gb"
  region      = "cdg"
  os_id       = 1743
  label       = "vultr-machine"
  hostname    = "vultr-machine"
  enable_ipv6 = false
  ssh_key_ids = ["60f8f596-14d5-4d06-a662-51ce92f4adf3"]
  script_id   = vultr_startup_script.startup_script.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "vultr_startup_script" "startup_script" {
  name   = "vultr-server-startup-script"
  type   = "boot"
  script = filebase64("${path.module}/startup_script.sh")
}
