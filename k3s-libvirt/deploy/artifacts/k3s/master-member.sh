#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/v1.26.8/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/v1.26.8/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token iaU7PyWu5smarL5EcZ6849rgBi7DvjYLbrcR:vc7bh3Pa2QpBv82vWDLr:YGxeB6728piRc7E2Xa0D8BeIR7swYJzdGNzT0M9XiyuFo7i:E: --write-kubeconfig-mode 644 --server https://10.10.10.11:6443

