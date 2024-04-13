# Libvirt 업데이트 

- 우분투의 경우 잘 생성되나, Centos / Rocky 등을 고정 IP로 생성하는 경우,
- Libvirt 네트워크 모듈을 Cloud Init Disk에 설정하지 않고
- Domiain 네트워크 항목에 직접 고정 IP를 설정하여 주어야 함


```bash
  network_interface {
    network_name = "${var.network_name}"
    addresses = [ "${var.prefixIP}.${each.value.octetIP}" ]
  }
```

---

``` bash
# Create the machine
resource "libvirt_domain" "k3s_nodes" {
  depends_on = [libvirt_volume.os_images]
  for_each = var.k3s_nodes

  # domain name in libvirt
  name   = "${each.key}-${var.prefixIP}.${each.value.octetIP}"
  memory = each.value.memoryMB
  vcpu   = each.value.vcpu

  disk { volume_id = libvirt_volume.os_images[each.key].id }

  network_interface {
    network_name = "${var.network_name}"
    addresses = [ "${var.prefixIP}.${each.value.octetIP}" ]
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
```
