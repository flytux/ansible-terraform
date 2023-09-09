#!/bin/sh
cd "${0%/*}"
NEW_VERSION=1.26.7
OLD_VERSION=$(/usr/local/bin/k3s --version | grep -oP 'v[1-9][^\s]+')

echo "=== stop k3s.service ==="
systemctl stop k3s.service

echo "=== new k3s version copied to /usr/local/bin"
mv /usr/local/bin/k3s k3s-$OLD_VERSION
cp ./$NEW_VERSION/k3s /usr/local/bin/k3s && chmod +x /usr/local/bin/k3s

echo "=== restart k3s.service ==="
systemctl restart k3s.service
