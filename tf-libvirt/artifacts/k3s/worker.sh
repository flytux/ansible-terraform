#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.122.213:6443 K3S_TOKEN=Nr6tiDeb5jeDjN9Z8cCqsCrFks7SBkqUdLGZhtSscfVGm3rPO9gMyDVMoEWNVjFc1hziQ2FLLzjK29AJHJGD5sVRp8PVzE0DLwIbXqyIheOy ./k3s/install.sh 

