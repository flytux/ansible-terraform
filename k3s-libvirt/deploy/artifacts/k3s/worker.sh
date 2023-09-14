#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.100.101:6443 K3S_TOKEN=1ecQa:wB6:qM7rcKkvQh0bLfCarkcRFQ3KcZ7b1F0OLthaxwPnai4QQLG8lPYXnzCJHX6tpLa3IxAfQQ2D1YnAlhWFEwGtWhOwxYHzKbILuD ./k3s/install.sh 

