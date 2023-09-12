#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_URL=https://192.168.122.213:6443 K3S_TOKEN=6QpD5lHo44Lj5AOsMp:o4pxOStWCPaxcCy:d58bXe:RhNC7OKsMVkcByT79FAdI3dZD2FKJu5br:yOfyL7W9SVe9RzoE:hCcvUSPkisXMdl3 ./k3s/install.sh 

