# OS images for libvirt VMs
resource "libvirt_volume" "os_image_workers" {
  for_each = local.workers
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
resource "libvirt_cloudinit_disk" "cloudinit_disk_workers" {
  for_each = local.workers
  name           = "${each.key}-cloudinit.iso"
  pool           = var.diskPool
  user_data      = data.template_file.cloud_init_workers[each.key].rendered
  network_config = data.template_file.network_config_workers[each.key].rendered
}

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
    user        = "${var.user}"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
  }

  provisioner "local-exec" {
    command = <<-EOT
              echo "${data.template_file.worker.rendered}" > artifacts/kubeadm/worker.sh
              EOT
  }

  provisioner "file" {
    source      = "artifacts/kubeadm"
    destination = "/root/kubeadm"
  }

  provisioner "file" {
    source      = ".ssh-default/id_rsa.key"
    destination = "/root/.ssh/id_rsa.key"
  }

  provisioner "remote-exec" {
    inline = [<<EOF
      chmod +x ./kubeadm/setup-kubeadm.sh
      sudo ./kubeadm/setup-kubeadm.sh
      chmod +x ./kubeadm/worker.sh
      sudo ./kubeadm/worker.sh
      chmod 400 .ssh/id_rsa.key
      JOIN_CMD=$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- kubeadm token create --print-join-command)
      $JOIN_CMD

      mkdir -p ~/.kube
      ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- cat /etc/kubernetes/admin.conf > $HOME/.kube/config
      sed -i "s/127\.0\.0\.1/{var.master_ip}/g" $HOME/.kube/config
      EOF
    ]
  }
 
}
