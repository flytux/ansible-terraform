#!/bin/sh
export RKE2_ROOT=/root/rke2/v1.28.8
mkdir -p /etc/rancher/rke2
cp ./rke2/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://192.168.122.11:9345' /etc/rancher/rke2/config.yaml

INSTALL_RKE2_ARTIFACT_PATH=$RKE2_ROOT sh $RKE2_ROOT/install.sh 
systemctl enable rke2-server.service --now

# Install kubectl
chmod +x $RKE2_ROOT/kubectl && mv $RKE2_ROOT/kubectl /usr/local/bin
mkdir -p $HOME/.kube && cp /etc/rancher/rke2/rke2.yaml $HOME/.kube/config
