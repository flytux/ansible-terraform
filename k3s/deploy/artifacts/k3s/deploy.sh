#!/bin/bash
ROLE=$(cat node-role)
if [[ "$ROLE" = master ]]
then
   echo "=== Staring Master Init node ==="
   chmod +x ./k3s/master-init.sh
   ./k3s/master-init.sh
elif [[ "$ROLE" = master-member ]]
then
   while ! curl -k https://192.168.122.21:6443 > /dev/null 2>&1; do echo wait for master node api-server up; sleep 5; done
   echo "=== Staring Master Member node ==="
   chmod +x ./k3s/master-member.sh
   ./k3s/master-member.sh
else
   while ! curl -k https://192.168.122.21:6443 > /dev/null 2>&1; do echo wait for master node api-server up; sleep 5; done
   echo "=== Staring Worker node ==="
   chmod +x ./k3s/worker.sh
   ./k3s/worker.sh
fi
