variable "prefixIP" { default = "192.168.122" }

variable "master_ip" { default = "192.168.122.21" }

variable "new_version" { default = "v1.28.8" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, octetIP = string}))
  default = { 
              kubeadm-master-1 = { role = "master-init", octetIP = "21"},
              kubeadm-worker-1 = { role = "worker",      octetIP = "22"},
              kubeadm-worker-2 = { role = "worker",      octetIP = "23"}
  }
}
