# OS images for libvirt VMs
resource "libvirt_volume" "os_image_masters" {
  for_each = local.masters
  name   = "${each.key}.qcow2"
  pool   = var.diskPool
  source = "artifacts/images/focal-server-cloudimg-amd64.img"
  format = "qcow2"

# Extend libvirt primary volume
  provisioner "local-exec" {
    command = <<EOF
      echo "Increment disk size by ${each.value.incGB}GB"
      sleep 10
      poolPath=$(virsh --connect ${var.qemu_connect} pool-dumpxml ${var.diskPool} | grep -Po '<path>\K[^<]+')
      sudo qemu-img resize $poolPath/${each.key}.qcow2 +${each.value.incGB}G
      sudo chgrp libvirt $poolPath/${each.key}.qcow2
      sudo chmod g+w $poolPath/${each.key}.qcow2
    EOF
  }
}

# Create cloud init disk
resource "libvirt_cloudinit_disk" "cloudinit_disk_masters" {
  for_each = local.masters
  name           = "${each.key}-cloudinit.iso"
  pool           = var.diskPool
  user_data      = data.template_file.cloud_init_masters[each.key].rendered
  network_config = data.template_file.network_config_masters[each.key].rendered
}

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
                     echo "${data.template_file.master-init.rendered}" > artifacts/kubeadm/master-init.sh
                else
                     echo "${data.template_file.master-member.rendered}" > artifacts/kubeadm/master-member.sh
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
    source      = "artifacts/kubeadm"
    destination = "/home/ubuntu/kubeadm"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      HOSTNAME=$(hostname) 
      if [ "$HOSTNAME" = "kubeadm-master-1" ]
        then
           chmod +x ./kubeadm/master-init.sh
           sudo ./kubeadm/master-init.sh
        else
           sleep 10 
           chmod +x ./kubeadm/master-member.sh
           sudo ./kubeadm/master-member.sh
      fi     
      EOF
    ]
  }
 
}
