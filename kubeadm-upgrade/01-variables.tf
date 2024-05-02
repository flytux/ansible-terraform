variable "master_ip" { default = "192.168.122.11" }

variable "new_version" { default = "v1.28.9" }

variable "ssh_key" { default = "../kvm/.ssh-default/id_rsa.key" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, ip = string}))
  default = { 
              kubeadm-master-1 = { role = "master-init", ip = "192.168.122.11"},
              kubeadm-worker-1 = { role = "worker",      ip = "192.168.122.21"},
  }
}
