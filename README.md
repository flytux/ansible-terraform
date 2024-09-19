# Terraform Kubernetes Provisioners

- K3S with libvirt provisioner
  - Multi master / worker node provisioning
  - Based on dmacvicar/libvirt
  - VM configure from https://fabianlee.org/
  - Airgapped install
  - Deploy v1.26.7 => Upgrade to v1.26.8
  - Minor upgrades support / Major upgrade require review of release notes

 ---
 
- Kubeadm with libvirt provisioner
  - Multi master / worker node provisioning
  - socat / conntrack deb package installed from cloud-init
  - Airgapped install
  - Deploy v1.26.7 => Upgrade to v1.26.8
  - Member master nodes deployed after 1st master node (init) installed and generate join token and cluster-endpoints certificates
  - Worker nodes deployed after master nodes are installed
  - Upgrade master init node first then upgarde master member nodes and worker nodes

---
    
- RKE2 with cilium cni
  - rke2-cilium
  - Instasll multi master cluster with RKE2
  - Install ciliume with ingress controller, load balancer
  
---
