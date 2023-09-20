resource "terraform_data" "prepare_installer" {
  depends_on = [libvirt_domain.k3s_nodes]

  provisioner "local-exec" {
    command = <<-EOT
                     echo "${data.template_file.master-init.rendered}"   > artifacts/k3s/master-init.sh
                     echo "${data.template_file.master-member.rendered}" > artifacts/k3s/master-member.sh
                     echo "${data.template_file.worker.rendered}"        > artifacts/k3s/worker.sh
                 EOT
  }
}

resource "terraform_data" "copy-installer" {
  depends_on = [terraform_data.prepare_installer]
  for_each = var.k3s_nodes
  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "root"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/k3s"
    destination = "/root/k3s"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      chmod +x k3s/deploy.sh
      ./k3s/deploy.sh
    EOF
    ]
  }
}

