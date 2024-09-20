resource "local_file" "deploy_outer" {
  content     = templatefile("${path.module}/artifacts/templates/deploy-outer.sh", {
                master_ip = var.master_ip
                nfs_pvc_root = var.nfs_pvc_root
                rancher_hostname =  var.rancher_hostname
              })
  filename = "${path.module}/artifacts/outer/deploy-outer.sh"
}
