variable "kube_version" {default = "v1.27.12" }
variable "prefix_ip" { default = "192.168.122" }

variable "master_ip" { default = "192.168.122.21" }

variable "join_cmd" { default = "$(ssh -i $HOME/.ssh/id_rsa.key -o StrictHostKeyChecking=no 192.168.122.21 -- cat join_cmd)" }

variable "kubeadm_home" { default = "artifacts/kubeadm" }

variable "kubeadm_nodes" { 

  type = map(object({ role = string, octetIP = string }))
  default = { 
              kb-master-1 = { role = "master-init", octetIP = "21" },
              kb-worker-1 = { role = "worker", octetIP = "22" },
              kb-worker-2 = { role = "worker", octetIP = "23" },
  }
}
