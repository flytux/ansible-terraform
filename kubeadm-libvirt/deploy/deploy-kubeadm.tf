resource "local_file" "master_init" {
    content     = templatefile("${path.module}/artifacts/templates/master-init.sh", {
                    master_ip = var.master_ip
                   })
    filename = "${path.module}/artifacts/kubeadm/master-init.sh"
}

resource "local_file" "master_member" {
  depends_on = [local_file.master_init]
    content     = templatefile("${path.module}/artifacts/templates/master-member.sh", {
		    master_ip = var.master_ip
		   })
    filename = "${path.module}/artifacts/kubeadm/master-member.sh"
}

resource "local_file" "worker" {
  depends_on = [local_file.master_member]
    content     = templatefile("${path.module}/artifacts/templates/worker.sh", {
		    master_ip = var.master_ip
		   })
    filename = "${path.module}/artifacts/kubeadm/worker.sh"
}

resource "terraform_data" "copy_installer" {
  depends_on = [local_file.worker]
  for_each = var.kubeadm_nodes
  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "root"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/kubeadm"
    destination = "/root/kubeadm"
  }

  provisioner "file" {
    source      = ".ssh-default/id_rsa.key"
    destination = "/root/.ssh/id_rsa.key"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
           chmod +x ./kubeadm/setup-kubeadm.sh
           sudo ./kubeadm/setup-kubeadm.sh
           chmod +x ./kubeadm/deploy.sh
           sudo ./kubeadm/deploy.sh
    EOF
    ]
  }
}

