variable "master_ip" { default = "192.168.122.21" }

variable "dns_domain" { default = "kubeworks.net" }

variable "k3s_version" { default = "v1.28.8+k3s1" }

variable "k3s_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
              k3s-master-1 = { role = "master", ip = "192.168.122.21" },
              k3s-worker-1 = { role = "worker", ip = "192.168.122.22" }
  }
}
