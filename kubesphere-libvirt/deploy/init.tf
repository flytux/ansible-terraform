# Local reference for VMs
locals {
  nodes = {
           "kubesphere-master-1" = { role = "master-init", os_code_name = "focal", octetIP = "151", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  #        "kubesphere-master-2" = { role = "master-member", os_code_name = "focal", octetIP = "152", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
           "kubesphere-worker-1" = { role = "worker", os_code_name = "focal", octetIP = "181", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "random_string" "token" {
  length           = 108
  special          = true
  numeric          = true
  lower            = true
  upper            = true
  override_special = ":"
}

resource "tls_private_key" "generic-ssh-key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" {
    command = <<EOF
      mkdir -p .ssh-${terraform.workspace}/
      echo "${tls_private_key.generic-ssh-key.private_key_openssh}" > .ssh-${terraform.workspace}/id_rsa.key
      echo "${tls_private_key.generic-ssh-key.public_key_openssh}" > .ssh-${terraform.workspace}/id_rsa.pub
      chmod 400 .ssh-${terraform.workspace}/id_rsa.key
      chmod 400 .ssh-${terraform.workspace}/id_rsa.key
    EOF
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf .ssh-${terraform.workspace}/
    EOF
  }
}

# OS images for libvirt VMs
resource "libvirt_volume" "os_images" {
  for_each = local.nodes
  name   = "${each.key}.qcow2"
  pool   = var.diskPool
  source = "artifacts/images/focal-server-cloudimg-amd64.img"
  format = "qcow2"

# Extend libvirt primary volume
  provisioner "local-exec" {
    command = <<EOF
      echo "Increment disk size by ${each.value.incGB}GB"
      sleep 10
      poolPath=$(virsh --connect ${var.qemu_connect} pool-dumpxml ${var.diskPool} | grep -Po '<path>\K[^<]+')
      sudo qemu-img resize $poolPath/${each.key}.qcow2 +${each.value.incGB}G
      sudo chgrp libvirt $poolPath/${each.key}.qcow2
      sudo chmod g+w $poolPath/${each.key}.qcow2
    EOF
  }
}

# Create cloud init disk
resource "libvirt_cloudinit_disk" "cloudinit_disks" {
  for_each = local.nodes
  name           = "${each.key}-cloudinit.iso"
  pool           = var.diskPool
  user_data      = data.template_file.cloud_inits[each.key].rendered
  network_config = data.template_file.network_configs[each.key].rendered
}

# Configure cloud-init 
data "template_file" "cloud_inits" {
  for_each = local.nodes
  template = file("${path.module}/artifacts/config/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn     = "${each.key}.${var.dns_domain}"
    password = var.password
    public_key = "${tls_private_key.generic-ssh-key.public_key_openssh}"
  }
}

# Configure network
data "template_file" "network_configs" {
  for_each = local.nodes
  template = file("${path.module}/artifacts/config/network_config_${var.ip_type}.cfg")
  vars = {
    domain   = var.dns_domain
    prefixIP = var.prefixIP
    octetIP  = each.value.octetIP
  }
}


