variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "192.168.122" }

variable "network_name" { default = "default" }

variable "dns_domain" { default = "kubeworks.net" }

variable "diskPool" { default = "default" }

variable "qemu_connect" { default = "qemu:///system" }

variable "cloud_image" { default = "focal-server-cloudimg-amd64.img" }

variable "nodes" { 
         type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number})) 
         default = {
           master-01 = { role = "master",  octetIP = "11" , vcpu = 8, memoryMB = 1024 * 24,  incGB = 200},
           worker-01 = { role = "worker",  octetIP = "21" , vcpu = 6, memoryMB = 1024 * 10,  incGB = 100},
           worker-02 = { role = "worker",  octetIP = "22" , vcpu = 6, memoryMB = 1024 * 10, incGB = 100},
  }
}
