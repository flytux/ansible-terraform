resource "multipass_instance" "multipass_vm" {
    count          = var.instance_count
    cloudinit_file = "${path.module}/user_data.cfg"
    name   = "${var.name_prefix}-${var.name}-${count.index + 1}"
    cpus           = var.cpus
    memory         = var.memory
    disk           = var.disks
    image          = var.image_name
} 

terraform {
  required_providers {
    multipass = {
      source = "larstobi/multipass"
      version = "1.4.2"
    }
  }
}

provider "multipass" {
  # Configuration options
}
