#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.100.101:6443 K3S_TOKEN=V4yZreiYCl3Jeares26IlK9OO4nC1MnTcZOOaatxcYJCvWdqlSh00vCqXOqiJd1MRq1D2:RxuLhyo94rnO33yQteR9N327eQA4pJptc7oOtV ./k3s/install.sh 

