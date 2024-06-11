resource "terraform_data" "node-token" {
  provisioner "local-exec" {
    command = "ssh -i ../kvm/.ssh-default/id_rsa.key ${var.master_ip} -- cat /var/lib/rancher/rke2/server/node-token > node-token"
  }
}

data "local_file" "node-token" {
  depends_on = [terraform_data.node-token]
  filename = "${path.module}/node-token"
}

resource "local_file" "cluster_config" {
  content     = templatefile("${path.module}/artifacts/templates/config.yaml", {
                token = data.local_file.node-token.content
                master_ip = var.master_ip
              })
  filename = "${path.module}/artifacts/rke2/config.yaml"
}

resource "local_file" "deploy" {
  depends_on = [local_file.cluster_config]
  content     = templatefile("${path.module}/artifacts/templates/deploy.sh", {
                token = data.local_file.node-token.content
                master_ip = var.master_ip
              })
  filename = "${path.module}/artifacts/rke2/deploy.sh"
}

resource "local_file" "master-init" {
  depends_on = [local_file.deploy]
  content     = templatefile("${path.module}/artifacts/templates/master-init.sh", {
                rke2_version = var.rke2_version
              })
  filename = "${path.module}/artifacts/rke2/master-init.sh"
}

resource "local_file" "master-member" {
  depends_on = [local_file.master-init]
  content     = templatefile("${path.module}/artifacts/templates/master-member.sh", {
                master_ip = var.master_ip
                rke2_version = var.rke2_version
              })
  filename = "${path.module}/artifacts/rke2/master-member.sh"
}

resource "local_file" "worker" {
  depends_on = [local_file.master-member]
  content     = templatefile("${path.module}/artifacts/templates/worker.sh", {
                master_ip = var.master_ip
                rke2_version = var.rke2_version
              })
  filename = "${path.module}/artifacts/rke2/worker.sh"
}

