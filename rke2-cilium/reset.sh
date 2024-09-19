#!/bin/bash

for node in node-01 node-02 node-03
do
  ssh $node rke2-uninstall.sh && ssh $node rm -rf rke2
done
