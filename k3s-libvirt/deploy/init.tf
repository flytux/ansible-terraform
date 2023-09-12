# Local reference for VMs
locals {
  masters = {
           "k3s-master-1" = { role = "master-init", os_code_name = "focal", octetIP = "213", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
           "k3s-master-2" = { role = "master-member", os_code_name = "focal", octetIP = "214", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
  workers = {
           "k3s-worker-1" = { role = "worker", os_code_name = "focal", octetIP = "223", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
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

data "template_file" "master-init" {
  template = file("artifacts/templates/master-init.sh")
  vars = {
    token     = random_string.token.result
  }
}

data "template_file" "master-member" {
  template = file("artifacts/templates/master-member.sh")
  vars = {
    token     = random_string.token.result
    master_ip = var.master_ip
  }
}

data "template_file" "worker" {
  template = file("artifacts/templates/worker.sh")
  vars = {
    token     = random_string.token.result
    master_ip = var.master_ip
  }
}


# OS images for libvirt VMs
resource "libvirt_volume" "os_image_masters" {
  for_each = local.masters
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
resource "libvirt_cloudinit_disk" "cloudinit_disk_masters" {
  for_each = local.masters
  name           = "${each.key}-cloudinit.iso"
  pool           = var.diskPool
  user_data      = data.template_file.cloud_init_masters[each.key].rendered
  network_config = data.template_file.network_config_masters[each.key].rendered
}

# Configure cloud-init 
data "template_file" "cloud_init_masters" {
  for_each = local.masters
  template = file("${path.module}/artifacts/config/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn     = "${each.key}.${var.dns_domain}"
    password = var.password
    public_key = "${tls_private_key.generic-ssh-key.public_key_openssh}"
  }
}

# Configure network
data "template_file" "network_config_masters" {
  for_each = local.masters
  template = file("${path.module}/artifacts/config/network_config_${var.ip_type}.cfg")
  vars = {
    domain   = var.dns_domain
    prefixIP = var.prefixIP
    octetIP  = each.value.octetIP
  }
}

# OS images for libvirt VMs
resource "libvirt_volume" "os_image_workers" {
  for_each = local.workers
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
resource "libvirt_cloudinit_disk" "cloudinit_disk_workers" {
  for_each = local.workers
  name           = "${each.key}-cloudinit.iso"
  pool           = var.diskPool
  user_data      = data.template_file.cloud_init_workers[each.key].rendered
  network_config = data.template_file.network_config_workers[each.key].rendered
}

# Configure cloud-init 
data "template_file" "cloud_init_workers" {
  for_each = local.workers
  template = file("${path.module}/artifacts/config/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn     = "${each.key}.${var.dns_domain}"
    password = var.password
    public_key = "${tls_private_key.generic-ssh-key.public_key_openssh}"
  }
}

# Configure network
data "template_file" "network_config_workers" {
  for_each = local.workers
  template = file("${path.module}/artifacts/config/network_config_${var.ip_type}.cfg")
  vars = {
    domain   = var.dns_domain
    prefixIP = var.prefixIP
    octetIP  = each.value.octetIP
  }
}

