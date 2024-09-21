variable "kube_version" {default = "v1.30.4" }

variable "ssh_key" {default = "../kvm/.ssh-default/id_rsa.key"}

variable "master_ip" { default = "192.168.122.11" }

variable "master_hostname" { default = "k8smaster" }

variable "pod_cidr" { default = "192.169.0.0/16" }

variable "kubeadm_home" { default = "artifacts/kubeadm" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
    master1  = { role = "master-init",  ip = "192.168.122.11" },
    master2  = { role = "master-member",ip = "192.168.122.12" },
    worker2  = { role = "worker",       ip = "192.168.122.13" },
  }
}
