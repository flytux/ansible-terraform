variable "password" { default = "linux" }

variable "ip_type" { default = "static" }

variable "prefixIP" { default = "192.168.122" }

variable "network_name" { default = "default" }

variable "dns_domain" { default = "kubeworks.net" }

variable "diskPool" { default = "images" }

variable "qemu_connect" { default = "qemu:///system" }
#variable "cloud_image" { default = "debian-12-generic-amd64-20240901-1857.qcow2" }
#variable "cloud_image" { default = "openSUSE-Leap-15.6.x86_64-1.0.1-NoCloud-Build1.39.qcow2" }
variable "cloud_image" { default = "Rocky-8-GenericCloud-Base.latest.x86_64.qcow2" }

variable "nodes" { 
         type = map(object({ role = string, octetIP = string , vcpu = number, memoryMB = number, incGB = number})) 
         default = {
          node-01 = { role = "m1",  octetIP = "11" , vcpu = 10, memoryMB = 1024 * 24, incGB = 300},
          #node-02 = { role = "m2",  octetIP = "12" , vcpu = 4, memoryMB = 1024 * 10, incGB = 100},
          #node-03 = { role = "w1",  octetIP = "13" , vcpu = 4, memoryMB = 1024 * 10, incGB = 100},
  }
}
