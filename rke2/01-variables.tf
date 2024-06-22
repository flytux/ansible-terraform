variable "master_ip" { default = "192.168.122.11" }

variable "rke2_version" { default = "v1.28.8" }

variable "rke2_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
              rke2-master =  { role = "master", ip = "192.168.122.11"},
              rke2-worker1 = { role = "worker", ip = "192.168.122.12"},
              rke2-worker2 = { role = "worker", ip = "192.168.122.13"}
  }
}
