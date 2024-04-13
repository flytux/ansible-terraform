#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.8+k3s1 sh -s - --token 6DVHKr0CKF:dNj96cwwSbANPexEWgXkZ:FKnVow0tvMVumDKcR7SZlqrxROfHoBu0bQqvuUcv9yRU2ukj0AMxPORA2iMEYOkCPMHCd6gBXu6 --write-kubeconfig-mode 644 --server https://192.168.122.21:6443
