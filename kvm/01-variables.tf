variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "192.168.122" }

variable "network_name" { default = "default" }

variable "dns_domain" { default = "kubeworks.net" }

variable "diskPool" { default = "default" }

variable "qemu_connect" { default = "qemu:///system" }

variable "cloud_image" { default = "ubuntu-22.04-server-cloudimg-amd64.img" }
#variable "cloud_image" { default = "focal-server-cloudimg-amd64.img" }

variable "nodes" { 
         type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number})) 
         default = {
          node-01 = { role = "m1",  octetIP = "11" , vcpu = 2, memoryMB = 1024 * 8, incGB = 100},
          node-02 = { role = "w1",  octetIP = "12" , vcpu = 5, memoryMB = 1024 * 10,incGB = 100},
          node-03 = { role = "w2",  octetIP = "13" , vcpu = 5, memoryMB = 1024 * 10,incGB = 100},
  }
}
