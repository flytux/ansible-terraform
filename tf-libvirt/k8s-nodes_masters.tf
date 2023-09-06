# Local reference for VMs
locals {
  masters = {
           "k3s-master-1" = { role = "master", os_code_name = "focal", octetIP = "213", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "random_string" "token" {
  length           = 108
  special          = true
  number           = true
  lower            = true
  upper            = true
  override_special = ":"
}


data "template_file" "master" {
  template = file("artifacts/templates/master.sh")
  vars = {
    token                  = random_string.token.result
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
  template = file("${path.module}/cfg/cloud_init.cfg")
  vars = {
    hostname = each.key
    fqdn     = "${each.key}.${var.dns_domain}"
    password = var.password
  }
}

# Configure network
data "template_file" "network_config_masters" {
  for_each = local.masters
  template = file("${path.module}/cfg/network_config_${var.ip_type}.cfg")
  vars = {
    domain   = var.dns_domain
    prefixIP = var.prefixIP
    octetIP  = each.value.octetIP
  }
}

# Create the machine
resource "libvirt_domain" "k8s_nodes_masters" {
  depends_on = [libvirt_volume.os_image_masters]
  for_each = local.masters
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_image_masters[each.key].id }

  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk_masters[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  provisioner "local-exec" {
    command = <<-EOT
              echo "${data.template_file.master.rendered}" > artifacts/k3s/master.sh
              EOT
  }

  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${file("cfg/id_rsa")}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/k3s"
    destination = "/home/ubuntu/k3s"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./k3s/master.sh",
      "sudo ./k3s/master.sh"
    ]
  }
 
}
