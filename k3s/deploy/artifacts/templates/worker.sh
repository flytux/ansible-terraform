#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=${k3s_version} K3S_URL=https://${master_ip}:6443 K3S_TOKEN=${token} sh -s -
