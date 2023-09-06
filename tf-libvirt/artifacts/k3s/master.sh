#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --cluster-init --token Nr6tiDeb5jeDjN9Z8cCqsCrFks7SBkqUdLGZhtSscfVGm3rPO9gMyDVMoEWNVjFc1hziQ2FLLzjK29AJHJGD5sVRp8PVzE0DLwIbXqyIheOy --write-kubeconfig-mode 644

