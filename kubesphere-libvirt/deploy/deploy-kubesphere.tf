data "template_file" "kubesphere-config" {
  template = templatefile("${path.module}/artifacts/templates/kubesphere-config.tpl", {
    master_nodes = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "master"}
    all_nodes    = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "all"}
    worker_nodes = {for key, val in var.kubesphere_nodes:
                    key => val if val.role == "worker"}
    prefixIP = var.prefixIP
    master_ip = var.master_ip
  })
}

resource "terraform_data" "config-out" {
  provisioner "local-exec" {
    command = <<-EOT
                 echo "${data.template_file.kubesphere-config.rendered}" |  sed '/^$/d' > artifacts/kubesphere/kubesphere-config.yml
              EOT
  }
}

resource "terraform_data" "install-kubesphere" {
  depends_on = [libvirt_domain.k8s_nodes]

  provisioner "local-exec" {
    command = <<EOF
      echo "Install kubesphere"
      artifacts/kubesphere/kk create cluster -f artifacts/kubesphere/kubesphere-config.yml -y
    EOF
  }

}
