locals {
  workers = {
           "kubeadm-worker-1" = { role = "worker", os_code_name = "focal", octetIP = "111", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "null_resource" "upgrade-worker" {
  depends_on = [null_resource.upgrade_master_member]

  for_each = local.workers

  provisioner "local-exec" {
    command = <<EOF
      echo "Create upgrade-worker.sh"
      sed -i "s/NEW_VERSION=.*/NEW_VERSION=${var.new_version}/" artifacts/kubeadm/upgrade-worker.sh
      cat artifacts/kubeadm/upgrade-worker.sh | grep NEW_VERSION
    EOF
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "artifacts/kubeadm/upgrade-worker.sh"
  destination = "/root/kubeadm/upgrade-worker.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./kubeadm/upgrade-worker.sh
      sudo ./kubeadm/upgrade-worker.sh
    EOF
    ]
  }

} 
