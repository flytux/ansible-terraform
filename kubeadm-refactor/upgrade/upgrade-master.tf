locals {
  masters = {
           "kubeadm-master-1" = { role = "master-init", os_code_name = "focal", octetIP = "101", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
           "kubeadm-master-2" = { role = "master-member", os_code_name = "focal", octetIP = "102", vcpu = 2, memoryMB = 1024 * 8, incGB = 30 }
  }
}

resource "null_resource" "upgrade_master_init" {

  for_each =  {for key, val in local.masters:
               key => val if val.role == "master-init"}

  provisioner "local-exec" {
    command = <<EOF
      echo "Create upgrade-master.sh"
      sed -i "s/NEW_VERSION=.*/NEW_VERSION=${var.new_version}/" artifacts/kubeadm/upgrade-master.sh
      sed -i "s/MASTER_IP=.*/MASTER_IP=${var.master_ip}/" artifacts/kubeadm/upgrade-master.sh
      cat artifacts/kubeadm/upgrade-master.sh | grep NEW_VERSION
    EOF
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "artifacts/kubeadm/upgrade-master.sh"
  destination = "/root/kubeadm/upgrade-master.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./kubeadm/upgrade-master.sh
      sudo ./kubeadm/upgrade-master.sh
    EOF
    ]
  }

} 

resource "null_resource" "upgrade_master_member" {
  depends_on = [null_resource.upgrade_master_init]

  for_each =  {for key, val in local.masters:
               key => val if val.role == "master-member"}

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "artifacts/kubeadm/upgrade-master.sh"
  destination = "/root/kubeadm/upgrade-master.sh"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      chmod +x ./kubeadm/upgrade-master.sh
      sudo ./kubeadm/upgrade-master.sh
    EOF
    ]
  }

} 
