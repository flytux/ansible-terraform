resource "terraform_data" "install" {
  depends_on = [local_file.worker]
  for_each = var.rke2_nodes
  connection {
    host        = "${each.value.ip}"
    user        = "root"
    type        = "ssh"
    private_key = file("${var.ssh_key_root}/.ssh-default/id_rsa.key")
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/rke2"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      echo ${each.value.role} > node-role
      chmod +x rke2/deploy.sh
      ./rke2/deploy.sh
    EOF
    ]
  }
}
