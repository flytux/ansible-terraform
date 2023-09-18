#!/bin/bash
cd "${0%/*}"
NEW_VERSION=v1.27.5
OLD_VERSION=$(/usr/local/bin/k3s --version | grep -oP 'v[1-9][^\s]+')

HOSTNAME=$(hostname)
if [[ "$HOSTNAME" =~ k3s-master.* ]]
then
    echo "=== Upgrade Master node ==="
    K3S_BIN=k3s
else
    echo "=== Upgrade Worker node ==="
    K3S_BIN=k3s-agent
fi

echo "=== stop k3s.service ==="
systemctl stop ${K3S_BIN}.service

echo "=== new k3s version copied to /usr/local/bin"
mv /usr/local/bin/k3s k3s-$OLD_VERSION
cp ./$NEW_VERSION/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s

echo "=== restart k3s.service ==="
systemctl restart ${K3S_BIN}.service
