#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token JvWk6Zqr64Aw0:njHhmVaKYkVYmuAuWmE4wAOD:0cXgVqe2imZ76LkcLnFbtZ6vgnQqWh6JZmvEcP2Rs0QXBgwiitTfW9kdmyEYnvSIbtCqI --write-kubeconfig-mode 644 --cluster-init

