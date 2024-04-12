#!/bin/bash
ROLE=$(cat node-role)
if [[ "$ROLE" = master ]]
then
   echo "=== Staring Master Init node ==="
   chmod +x ./rke2/master-init.sh
   ./rke2/master-init.sh
elif [[ "$ROLE" = master-member ]]
then
   while ! curl -k https://192.168.122.21:9345 > /dev/null 2>&1; do echo wait for master node api-server up; sleep 5; done
   echo "=== Staring Master Member node ==="
   chmod +x ./rke2/master-member.sh
   ./rke2/master-member.sh
else
   while ! curl -k https://192.168.122.21:9345 > /dev/null 2>&1; do echo wait for master node api-server up; sleep 5; done
   echo "=== Staring Worker node ==="
   chmod +x ./rke2/worker.sh
   ./rke2/worker.sh
fi
