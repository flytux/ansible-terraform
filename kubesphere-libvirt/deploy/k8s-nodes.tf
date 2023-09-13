# Create the machine
resource "libvirt_domain" "k8s_nodes" {
  depends_on = [libvirt_volume.os_images]
  for_each = local.nodes
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_images[each.key].id }

  network_interface {
    network_name = "default"
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
    source      = "artifacts/containerd"
    destination = "/root/containerd"
  }

  provisioner "file" {
    source      = "artifacts/images/kubesphere-v1.23.10.tar"
    destination = "/root/containerd/kubesphere-v1.23.10.tar"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
           chmod +x ./containerd/setup.sh
           ./containerd/setup.sh
      EOF
    ]
  }

}
