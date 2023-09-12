locals {
  workers = {
           "k3s-worker-1" = { role = "worker", os_code_name = "focal", octetIP = "223", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "null_resource" "upgrade-worker" {
  depends_on = [null_resource.upgrade-master]

  for_each = local.workers

  provisioner "local-exec" {
    command = <<EOF
      echo "Create upgrade-worker.sh"
      sed -i "s/NEW_VERSION=.*/NEW_VERSION=${var.new_version}/" k3s/upgrade-worker.sh
      cat k3s/upgrade-worker.sh | grep NEW_VERSION
    EOF
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "k3s/upgrade-worker.sh"
  destination = "/root/k3s/upgrade-worker.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./k3s/upgrade-worker.sh
      sudo ./k3s/upgrade-worker.sh
    EOF
    ]
  }

} 
