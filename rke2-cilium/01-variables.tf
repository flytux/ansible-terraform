variable "tls_san" { default = "rke2-master" }

variable "master_ip" { default = "192.168.122.11" }

variable "rke2_version" { default = "v1.30.4" }

variable "ssh_key_root" { default = "/root/works/terraform-kube/kvm" }

variable "rke2_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
              rke2-master1 = { role = "master", ip = "192.168.122.11"},
              #rke2-master2 = { role = "master-member", ip = "192.168.122.12"},
              #rke2-master3 = { role = "worker", ip = "192.168.122.13"}
  }
}
