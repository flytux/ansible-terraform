variable "kube_version" {default = "v1.28.8" }

variable "ssh_key" {default = "../kvm/.ssh-default/id_rsa.key"}

variable "master_ip" { default = "192.168.122.11" }

variable "kubeadm_home" { default = "artifacts/kubeadm" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
              master-1 = { role = "master-init",   ip = "192.168.122.11" },
              #master-2 = { role = "master-member", ip = "192.168.122.12" },
              #worker-1 = { role = "worker",        ip = "192.168.122.21" },
  }
}
