resource "random_string" "token" {
  length           = 108
  special          = true
  numeric          = true
  lower            = true
  upper            = true
  override_special = ":"
}

resource "local_file" "deploy" {
  content     = templatefile("${path.module}/artifacts/templates/deploy.sh", {
                master_ip = var.master_ip
              })
  filename = "${path.module}/artifacts/k3s/deploy.sh"
}

resource "local_file" "master-init" {
  content     = templatefile("${path.module}/artifacts/templates/master-init.sh", {
                master_ip = var.master_ip
                k3s_version = var.k3s_version
                token = random_string.token.result
              })
  filename = "${path.module}/artifacts/k3s/master-init.sh"
}

resource "local_file" "master-member" {
  content     = templatefile("${path.module}/artifacts/templates/master-member.sh", {
                master_ip = var.master_ip
                k3s_version = var.k3s_version
                token = random_string.token.result
              })
  filename = "${path.module}/artifacts/k3s/master-member.sh"
}

resource "local_file" "worker" {
  content     = templatefile("${path.module}/artifacts/templates/worker.sh", {
                master_ip = var.master_ip
                k3s_version = var.k3s_version
                token = random_string.token.result
              })
  filename = "${path.module}/artifacts/k3s/worker.sh"
}
