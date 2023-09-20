#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.100.101:6443 K3S_TOKEN=2PnfmQzsvPe:TaU6Cd2MKkVgnrOJqvAUPg64iBxoOYiKP2bWEIcLEkxQJ6DiaNG0L5rlld1DG3bFlEecWGz5fxycDeLFkEhyU8W5uIbrI5Hb ./k3s/install.sh 

