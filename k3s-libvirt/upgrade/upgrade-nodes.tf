resource "terraform_data" "upgrade-nodes" {

  for_each = var.k3s_nodes

  provisioner "local-exec" {
    command = <<EOF
      echo "Create upgrade-nodes.sh"
      sed -i "s/NEW_VERSION=.*/NEW_VERSION=${var.new_version}/" k3s/upgrade-nodes.sh
      cat k3s/upgrade-nodes.sh | grep NEW_VERSION
    EOF
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "k3s/upgrade-nodes.sh"
  destination = "/root/k3s/upgrade-nodes.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./k3s/upgrade-nodes.sh
      sudo ./k3s/upgrade-nodes.sh
    EOF
    ]
  }

} 
