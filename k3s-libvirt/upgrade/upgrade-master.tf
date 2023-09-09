locals {
  masters = {
           "k3s-master-1" = { role = "master-init", os_code_name = "focal", octetIP = "213", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
           "k3s-master-2" = { role = "master-member", os_code_name = "focal", octetIP = "214", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "null_resource" "upgrade-master" {

  for_each = local.masters

  provisioner "local-exec" {
    command = <<EOF
      echo "Create upgrade-master.sh"
      sed -i "s/NEW_VERSION=.*/NEW_VERSION=${var.new_version}/" k3s/upgrade-master.sh
      cat k3s/upgrade-master.sh | grep NEW_VERSION
    EOF
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "k3s/upgrade-master.sh"
  destination = "/home/ubuntu/k3s/upgrade-master.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./k3s/upgrade-master.sh
      sudo ./k3s/upgrade-master.sh
    EOF
    ]
  }

} 
