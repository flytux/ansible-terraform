# Create the machine
resource "libvirt_domain" "k8s_nodes" {
  depends_on = [libvirt_volume.os_images]
  for_each = var.kubesphere_nodes
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_images[each.key].id }

  network_interface {
    network_name = "nat100"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disks[each.key].id

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

  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "root"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "artifacts/images/kubesphere-v1.23.10.tar"
    destination = "/root/kubesphere-v1.23.10.tar"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      apt install socat conntrack containerd -y
      ctr i import kubesphere-v1.23.10.tar
    EOF
    ]
  }

}
