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
              fi 
              EOT
  }

  connection {
    host        = "${var.prefixIP}.${each.value.octetIP}"
    user        = "${var.user}"
    type        = "ssh"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    timeout     = "1m"
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
      HOSTNAME=$(hostname) 
      echo $HOSTNAME ">>> Running Kubeadm Init"
      if [ "$HOSTNAME" = "kubeadm-master-1" ]
        then
           chmod +x ./kubeadm/setup-kubeadm.sh
           chmod +x ./kubeadm/master-init.sh
           sudo ./kubeadm/setup-kubeadm.sh
           sudo ./kubeadm/master-init.sh
        else
           chmod +x ./kubeadm/setup-kubeadm.sh
           sudo ./kubeadm/setup-kubeadm.sh
      fi     
      EOF
    ]
  }
}

resource "null_resource" "add-master" {
  depends_on = [libvirt_domain.k8s_nodes_masters]

  #for_each = local.master-members

  for_each =  {for key, val in local.masters:
               key => val if val.role == "master-member"}

  connection {
    type        = "ssh"
    user        = "${var.user}"
    private_key = "${tls_private_key.generic-ssh-key.private_key_openssh}"
    host        = "${var.prefixIP}.${each.value.octetIP}"
  }

  provisioner "remote-exec" {
  inline = [<<EOF
           chmod 400 .ssh/id_rsa.key
           JOIN=$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no ${var.master_ip} -- cat join_cmd | tr '\\' ' ')
           $JOIN
    EOF
    ]
  }

}

