#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.28.8+k3s1 K3S_URL=https://192.168.122.21:6443 K3S_TOKEN=6DVHKr0CKF:dNj96cwwSbANPexEWgXkZ:FKnVow0tvMVumDKcR7SZlqrxROfHoBu0bQqvuUcv9yRU2ukj0AMxPORA2iMEYOkCPMHCd6gBXu6 sh -s -
