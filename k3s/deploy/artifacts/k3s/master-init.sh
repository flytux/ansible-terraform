#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.8+k3s1 sh -s - --token 6DVHKr0CKF:dNj96cwwSbANPexEWgXkZ:FKnVow0tvMVumDKcR7SZlqrxROfHoBu0bQqvuUcv9yRU2ukj0AMxPORA2iMEYOkCPMHCd6gBXu6 --write-kubeconfig-mode 644 --cluster-init

# Airgapped
#mkdir -p /var/lib/rancher/k3s/agent/images/
#cp ./k3s/v1.28.8+k3s1/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
#cp ./k3s/v1.28.8+k3s1/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
#chmod +x ./k3s/install.sh
#INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token 6DVHKr0CKF:dNj96cwwSbANPexEWgXkZ:FKnVow0tvMVumDKcR7SZlqrxROfHoBu0bQqvuUcv9yRU2ukj0AMxPORA2iMEYOkCPMHCd6gBXu6 --write-kubeconfig-mode 644 --cluster-init
