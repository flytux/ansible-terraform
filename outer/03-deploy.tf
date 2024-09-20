resource "terraform_data" "install" {
  depends_on = [local_file.deploy_outer]
  connection {
    host        = "${var.master_ip}"
    user        = "root"
    type        = "ssh"
    private_key = file("${var.ssh_key_root}/.ssh-default/id_rsa.key")
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/outer"
    destination = "/root"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      chmod +x outer/deploy-outer.sh
      ./outer/deploy-outer.sh
    EOF
    ]
  }
}
