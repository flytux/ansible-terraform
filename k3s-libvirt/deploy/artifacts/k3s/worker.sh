#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.100.101:6443 K3S_TOKEN=KXvKIozUnGNp6bPuQvU0EU3wj46SHaVx1PBWSE01F9b9aJI7y6aESyachzw2:qvhzMm4Wi5Z5Sj0bH7YP0Q97ZmOaVmm79g965stsVIVlqKn ./k3s/install.sh 

