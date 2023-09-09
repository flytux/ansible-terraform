#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token U0RMw9VLhk7qo5TumglE5l5aH7lipEFdzOO38MNmhXGkU0KK:2ZGW6fmNZrcKn2yJrCbR:mXn9tOjCnDR8:7970:OH7fw3d3GSoRoCNmZhjr --write-kubeconfig-mode 644 --server https://192.168.122.213:6443

