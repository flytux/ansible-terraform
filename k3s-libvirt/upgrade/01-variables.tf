variable "new_version" { default = "v1.27.6" }

variable "prefixIP" { default = "10.10.10" }

variable "k3s_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              k3s-master-1 = { role = "master", octetIP = "11" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
              k3s-worker-1 = { role = "worker", octetIP = "21" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
  }
}
