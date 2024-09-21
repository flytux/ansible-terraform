#!/bin/bash

for node in node-01 node-02 node-03
do
  echo "==== kubeadm reset ===="
  ssh $node kubeadm reset --force
  echo "==== clean cni plugins & iptables ===="
  ssh $node rm -rf kubeadm && rm -rf /etc/cni/net.d 
done
