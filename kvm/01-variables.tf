variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "192.168.122" }

variable "network_name" { default = "default" }

variable "dns_domain" { default = "kubeworks.net" }

variable "diskPool" { default = "default" }

variable "qemu_connect" { default = "qemu:///system" }

variable "cloud_image" { default = "Rocky-8-GenericCloud-8.6.20220702.0.x86_64.qcow2" }
#variable "cloud_image" { default = "focal-server-cloudimg-amd64.img" }

variable "nodes" { 
         type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number})) 
         default = {
           #mgmt1 = { role = "master",   octetIP = "11" , vcpu = 2, memoryMB = 1024 * 8, incGB = 200},
           svc1 = { role = "master",   octetIP = "21" , vcpu = 2, memoryMB = 1024 * 4, incGB = 100},
           svc2 = { role = "worker",   octetIP = "22" , vcpu = 4, memoryMB = 1024 * 8, incGB = 100},
           svc3 = { role = "worker",   octetIP = "23" , vcpu = 4, memoryMB = 1024 * 8, incGB = 100},
  }
}
