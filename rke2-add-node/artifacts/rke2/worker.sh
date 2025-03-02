#!/bin/sh
export RKE2_ROOT=/root/rke2/v1.28.8
mkdir -p /etc/rancher/rke2
cp ./rke2/config.yaml /etc/rancher/rke2/
sed -i '1iserver: https://192.168.122.11:9345' /etc/rancher/rke2/config.yaml

INSTALL_RKE2_ARTIFACT_PATH=$RKE2_ROOT INSTALL_RKE2_TYPE="agent" sh $RKE2_ROOT/install.sh
systemctl enable rke2-agent.service --now
