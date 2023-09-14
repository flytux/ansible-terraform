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
    
- Kubesphere with libvirt provisioner (23.09.14)
  - Multi master / worker node provsioning
  - Added node role all (master + worker)
  - Socat / conntrack deb package installed from package file to execture remnotely
  - Terraform null_resource => terraform_data changed
  - Using templatefile to generate dynamic kubesphere config
  - VM information moved to variables from local data

---
