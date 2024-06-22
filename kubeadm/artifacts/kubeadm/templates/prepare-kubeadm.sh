#!/bin/sh

# Rocky
# Disble SELINUX 
#setenforce 0
#sed -i --follow-symlinks 's/SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux
#
#dnf install -y dnf-utils
#dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#dnf install -y containerd.io socat conntrack iproute-tc iptables-ebtables iptables
#dnf install -y kubeadm/packages/*.rpm

# Ubuntu
# Add k8smaster IP
echo "${master_ip}    ${master_hostname}" >> /etc/hosts

# Swap off
swapoff -a                 
sed -e '/swap/ s/^#*/#/' -i /etc/fstab  

# Install containred
dpkg -i kubeadm/packages/*.deb

# Config containerd
mkdir -p /etc/containerd
cp kubeadm/packages/config.toml /etc/containerd/

mkdir -p /etc/nerdctl
cp kubeadm/kubernetes/config/nerdctl.toml /etc/nerdctl/nerdctl.toml

systemctl restart containerd

# Copy kubeadm and network binaries
cp kubeadm/kubernetes/bin/* /usr/local/bin
chmod +x /usr/local/bin/*
cp -R kubeadm/cni /opt
chmod +x /opt/cni/bin/*

# Load kubeadm container images
#nerdctl load -i kubeadm/images/kubeadm.tar

# Configure and start kubelet
cp kubeadm/kubernetes/config/kubelet.service /etc/systemd/system
mv kubeadm/kubernetes/config/kubelet.service.d /etc/systemd/system

systemctl daemon-reload
systemctl enable kubelet --now
