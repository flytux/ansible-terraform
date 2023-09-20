variable "new_version" { default = "v1.27.5" }

variable "prefixIP" { default = "192.168.100" }

variable "k3s_nodes" { 

  type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number}))
  default = { 
              k3s-master-1 = { role = "master", octetIP = "101" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30},
              k3s-worker-1 = { role = "worker", octetIP = "201" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
              k3s-master-2 = { role = "worker", octetIP = "102" , vcpu = 2, memoryMB = 1024 * 8, incGB = 30}
  }
}
