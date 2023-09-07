locals {
  masters = {
           "kubeadm-master-1" = { role = "master-init", os_code_name = "focal", octetIP = "101", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
  workers = {
           "kubeadm-worker-1" = { role = "worker", os_code_name = "focal", octetIP = "111", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
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
  }
}

data "template_file" "master-member" {
  template = file("artifacts/templates/master-member.sh")
  vars = {
    master_ip = var.master_ip
  }
}

data "template_file" "worker" {
  template = file("artifacts/templates/worker.sh")
  vars = {
    master_ip = var.master_ip
  }
}

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

data "template_file" "network_config_masters" {
  for_each = local.masters
  template = file("${path.module}/artifacts/config/network_config_${var.ip_type}.cfg")
  vars = {
    domain   = var.dns_domain
    prefixIP = var.prefixIP
    octetIP  = each.value.octetIP
  }
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

