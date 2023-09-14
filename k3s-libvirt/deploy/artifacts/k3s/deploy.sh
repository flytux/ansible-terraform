#!/bin/bash
HOSTNAME=$(hostname)
if [[ "$HOSTNAME" =~ k3s-master-1 ]]
then
    echo "=== Staring Master Init node ==="
    chmod +x ./k3s/master-init.sh
    ./k3s/master-init.sh
elif [[ "$HOSTNAME" =~ k3s-master.* ]]
then
    sleep 10
    echo "=== Staring Master Member node ==="
    chmod +x ./k3s/master-member.sh
    ./k3s/master-member.sh
else
    sleep 10
    echo "=== Staring Worker node ==="
    chmod +x ./k3s/worker.sh
    ./k3s/worker.sh
fi
