# Create the machine
resource "libvirt_domain" "nodes" {
  depends_on = [libvirt_volume.os_images]
  for_each = var.nodes
  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_images[each.key].id }

  network_interface {
    network_name = "default"
    addresses = ["${var.prefixIP}.${each.value.octetIP}"]
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
}
