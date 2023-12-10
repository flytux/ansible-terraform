#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -s - --token ${token} --write-kubeconfig-mode 644 --cluster-init

# Airgapped
#mkdir -p /var/lib/rancher/k3s/agent/images/
#cp ./k3s/${k3s_version}/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
#cp ./k3s/${k3s_version}/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
#chmod +x ./k3s/install.sh
#INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token ${token} --write-kubeconfig-mode 644 --cluster-init
