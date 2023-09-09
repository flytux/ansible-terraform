# Create the machine
resource "libvirt_domain" "k8s_nodes_workers" {
  depends_on = [libvirt_domain.k8s_nodes_masters]
  for_each = local.workers
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_image_workers[each.key].id }

  network_interface {
    network_name = "default"
  }

  cloudinit = libvirt_cloudinit_disk.cloudinit_disk_workers[each.key].id

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
    user        = "ubuntu"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "local-exec" {
    command = <<-EOT
              echo "${data.template_file.worker.rendered}" > artifacts/k3s/worker.sh
              EOT
  }

  provisioner "file" {
    source      = "artifacts/k3s"
    destination = "/home/ubuntu/k3s"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x ./k3s/worker.sh",
      "sudo ./k3s/worker.sh"
    ]
  }
 
}
