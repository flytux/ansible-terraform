resource "null_resource" "install-kubesphere" {
  depends_on = [libvirt_domain.k8s_nodes]

  provisioner "local-exec" {
    command = <<EOF
      echo "Install kubesphere"
      artifacts/kubesphere/kk create cluster -f artifacts/kubesphere/kubesphere-config.yml -y
    EOF
  }

}
