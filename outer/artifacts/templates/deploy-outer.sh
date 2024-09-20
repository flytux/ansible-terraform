#!/bin/bash

echo "==== Start installing outer services ===="

echo "==== 1) Install Cert-manager ===="

helm repo add jetstack https://charts.jetstack.io --force-update

helm upgrade -i --wait \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.15.3 \
  --set crds.enabled=true

echo "==== 2) Install Rancher ===="

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm repo update

helm upgrade -i rancher rancher-latest/rancher \
--set hostname=${rancher_hostname} --set bootstrapPassword=admin \
--set replicas=1 --set global.cattle.psp.enabled=false \
--set auditLog.level=1 \
--create-namespace -n cattle-system

echo "==== 3) NFS-CSI Storage Class ===="
apt install nfs-server -y # Ubuntu

mkdir -p ${nfs_pvc_root}
chmod 707 ${nfs_pvc_root}
chown -R 65534:65534 ${nfs_pvc_root}

cat << EOF >> /etc/exports
${nfs_pvc_root} 192.168.122.11(rw,sync,no_root_squash)
${nfs_pvc_root} 192.168.122.12(rw,sync,no_root_squash)
${nfs_pvc_root} 192.168.122.13(rw,sync,no_root_squash)
EOF

systemctl enable nfs-server --now

exportfs -v

curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v4.5.0/deploy/install-driver.sh | bash -s v4.5.0 --

sleep 15

cat <<EOF > nfs-sc.yml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: ${master_ip} 
  share: ${nfs_pvc_root} 
  mountPermissions: "0777"
reclaimPolicy: Retain 
volumeBindingMode: Immediate
mountOptions:
  - nfsvers=4.1
EOF

kubectl apply -f nfs-sc.yml

kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/pvc-nfs-csi-dynamic.yaml

kubectl get pvc

kubectl patch storageclass nfs-csi -n kube-system -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "==== 4) NVIDUA GPU Operator ===="

kubectl -n kube-system  apply -f - <<"EOF"
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: gpu-operator
  namespace: kube-system
spec:
  repo: https://helm.ngc.nvidia.com/nvidia
  chart: gpu-operator
  targetNamespace: gpu-operator
  createNamespace: true
  valuesContent: |-
    toolkit:
      env:
      - name: CONTAINERD_SOCKET
        value: /run/k3s/containerd/containerd.sock
EOF

