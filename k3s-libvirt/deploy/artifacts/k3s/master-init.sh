#!/bin/sh
mkdir -p /var/lib/rancher/k3s/agent/images/
cp ./k3s/k3s-airgap-images-amd64.tar.gz /var/lib/rancher/k3s/agent/images/k3s-airgap-images-amd64.tar.gz
cp ./k3s/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s
chmod +x ./k3s/install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true ./k3s/install.sh --token BwVwNxX5TmEh4BrGD1CoXamWR8Lb3JrsdrSbH2opeTddao5eMZMpcjruWvaAA0kihF6KC1z58JVOAE9O5ntJXoXIlYK9D4MWRRr6WFyjcfQB --write-kubeconfig-mode 644 --cluster-init

