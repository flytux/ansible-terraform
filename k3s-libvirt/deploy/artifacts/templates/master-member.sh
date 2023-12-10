#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} sh -s - --token ${token} --write-kubeconfig-mode 644 --server https://${master_ip}:6443
