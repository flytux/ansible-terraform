
data "template_file" "master-init" {
  template = file("artifacts/templates/master-init.sh")
  vars = {
    master_ip = var.master_ip
  }
}

data "template_file" "master-member" {
  template = file("artifacts/templates/master-member.sh")
  vars = {
    master_ip = var.master_ip
  }
}

data "template_file" "worker" {
template = file("artifacts/templates/worker.sh")
vars = {
master_ip = var.master_ip
}
}

resource "terraform_data" "prepare_installer" {
  depends_on = [libvirt_domain.kubeadm_nodes]


  provisioner "local-exec" {
    command = <<-EOT
                     echo "${data.template_file.master-init.rendered}" > artifacts/kubeadm/master-init.sh
                     echo "${data.template_file.worker.rendered}" > artifacts/kubeadm/worker.sh
                 EOT
  }

}

resource "terraform_data" "copy_installer" {
  depends_on = [terraform_data.prepare_installer]
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
    EOF
    ]
  }
}

resource "terraform_data" "init_master" {
  depends_on = [terraform_data.copy_installer]

  for_each =  {for key, val in var.kubeadm_nodes:
               key => val if val.role == "master-init"}

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
           chmod +x ./kubeadm/master-init.sh
           sudo ./kubeadm/master-init.sh
    EOF
    ]
  }
}

resource "terraform_data" "add_master" {
  depends_on = [terraform_data.init_master]

  for_each =  {for key, val in var.kubeadm_nodes:
               key => val if val.role == "master-member"}

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
           chmod 400 .ssh/id_rsa.key
           JOIN=$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- cat join_cmd | tr '\\' ' ')
           $JOIN
    EOF
    ]
  }
}

resource "terraform_data" "add_worker" {
  depends_on = [terraform_data.init_master]

  for_each =  {for key, val in var.kubeadm_nodes:
               key => val if val.role == "worker"}

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
           chmod +x ./kubeadm/worker.sh
           sudo ./kubeadm/worker.sh
           chmod 400 .ssh/id_rsa.key
           JOIN_CMD=$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- kubeadm token create --print-join-command)
           $JOIN_CMD

           mkdir -p ~/.kube
           ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- cat /etc/kubernetes/admin.conf > $HOME/.kube/config
           sed -i "s/127\.0\.0\.1/{var.master_ip}/g" $HOME/.kube/config

    EOF
    ]
  }
}

