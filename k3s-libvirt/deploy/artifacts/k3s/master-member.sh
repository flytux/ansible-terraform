#!/bin/sh
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.27.8+k3s2 sh -s - --token XC8gi4zUTczZLfmqYS5LgL6S1Op67y43IASyKruXH7mFJcXdXTlxPJCsYg90DvxZQRzrEWtnAINdMQqQbDdiSbxBC1LQZhfs83T9Oqjh4KZt --write-kubeconfig-mode 644 --server https://10.10.10.11:6443

