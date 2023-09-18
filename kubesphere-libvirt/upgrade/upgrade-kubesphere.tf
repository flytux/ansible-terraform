data "template_file" "kubesphere-upgrade-config" {
  template = templatefile("${path.module}/artifacts/templates/kubesphere-upgrade-config.tpl", {
    master_nodes = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "master"}
    all_nodes    = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "all"}
    worker_nodes = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "worker"}
    upgrade_version = var.upgrade_version
    master_ip = var.master_ip
    prefixIP = var.prefixIP
  })
}

resource "terraform_data" "config-out" {
  provisioner "local-exec" {
    command = <<-EOT
                 echo "${data.template_file.kubesphere-upgrade-config.rendered}" |  sed '/^$/d' > artifacts/kubesphere/kubesphere-upgrade-config.yml
              EOT
  }
}

resource "terraform_data" "prepare_upgrade" {

  for_each =  var.kubesphere_nodes

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file("${path.module}/../deploy/.ssh-default/id_rsa.key")
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "file" {
  source      = "artifacts/images/kubesphere-${var.upgrade_version}.tar"
  destination = "/root/kubesphere-upgrade.tar"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
      ctr i import kubesphere-upgrade.tar
    EOF
    ]
  }

} 

resource "terraform_data" "upgrade_kubesphere" {
  depends_on = [terraform_data.prepare_upgrade]

  provisioner "local-exec" {
  command = <<EOF
      echo "Upgrade kubesphere"
      artifacts/kubesphere/kk upgrade cluster -f artifacts/kubesphere/kubesphere-upgrade-config.yml -y
    EOF
    
  }
} 
