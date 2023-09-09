# Create the machine
resource "libvirt_domain" "k8s_nodes_masters" {
  depends_on = [libvirt_volume.os_image_masters]
  for_each = local.masters
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_image_masters[each.key].id }

  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk_masters[each.key].id

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = "true"
  }

  provisioner "local-exec" {
    command = <<-EOT
              if [ "${each.value.role}" = "master-init" ]
                then
                     echo "${data.template_file.master-init.rendered}" > artifacts/k3s/master-init.sh
                else
                     echo "${data.template_file.master-member.rendered}" > artifacts/k3s/master-member.sh
              fi 
              EOT
  }

  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/k3s"
    destination = "/home/ubuntu/k3s"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      HOSTNAME=$(hostname) 
      if [ "$HOSTNAME" = "k3s-master-1" ]
        then
           chmod +x ./k3s/master-init.sh
           sudo ./k3s/master-init.sh
        else
           sleep 10 
           chmod +x ./k3s/master-member.sh
           sudo ./k3s/master-member.sh
      fi     
      EOF
    ]
  }
 
}
