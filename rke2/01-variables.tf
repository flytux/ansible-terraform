variable "master_ip" { default = "192.168.122.21" }

variable "rke2_version" { default = "v1.28.8" }

variable "rke2_nodes" { 

  type = map(object({ role = string, ip = string }))
  default = { 
              rke2-master-1 = { role = "master", ip = "192.168.122.21"},
              rke2-worker-1 = { role = "worker", ip = "192.168.122.22"},
              rke2-worker-2 = { role = "worker", ip = "192.168.122.23"}
  }
}
