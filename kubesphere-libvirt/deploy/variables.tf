variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "192.168.122" }

variable "master_ip" { default = "192.168.122.151" }

variable "dns_domain" { default = "kubeworks.net" }

variable "diskPool" { default = "default" }

variable "qemu_connect" { default = "qemu:///system" }

variable "kubesphere_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              kubesphere-master-1 = { role = "master", octetIP = "151" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
              kubesphere-worker-1 = { role = "worker", octetIP = "181" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
              kubesphere-master-2 = { role = "all",    octetIP = "152" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
  }
}


