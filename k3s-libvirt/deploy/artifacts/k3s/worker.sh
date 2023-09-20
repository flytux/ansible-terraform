#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://10.10.10.11:6443 K3S_TOKEN=ITXEheO9CLv675W:z:yi8T52RMPqB5u:orfoQc8v1koCJVlcpYKWpaFx7BQpVHX6B5t1pLyYPMF876WkkZSriUgbooGF9dOdZUhQ4DOHTN9J ./k3s/install.sh 

