resource "terraform_data" "copy-installer" {
  depends_on = [resource.local_file.worker]
  for_each = var.k3s_nodes
  connection {
    host        = "${each.value.ip}"
    user        = "root"
    type        = "ssh"
    private_key = file("/root/works/kvm/.ssh-default/id_rsa.key")
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/k3s"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      echo ${each.value.role} > node-role
      chmod +x k3s/deploy.sh
      ./k3s/deploy.sh
    EOF
    ]
  }
}


