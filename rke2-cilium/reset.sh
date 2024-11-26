#!/bin/bash

for node in node-01  node-02
do
  ssh $node rke2-uninstall.sh && ssh $node rm -rf rke2
done
