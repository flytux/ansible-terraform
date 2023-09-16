#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token Y8NhbcBb41EQZ8puuw2D3Xs6hsMasse7Bi3KVBimqsweBVmOt847o5zcrZB0cfJKJYnBEic3qYPpyp8GqHUhkC8iFVoGbZIm89Khvmph9oAX --write-kubeconfig-mode 644 --cluster-init

