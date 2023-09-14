apiVersion: kubekey.kubesphere.io/v1alpha2
kind: Cluster
metadata:
  name: sample
spec:
  hosts:
%{ for k, v in master_nodes }
  - {name: ${k}, address: ${prefixIP}.${v.octetIP}, internalAddress: ${prefixIP}.${v.octetIP}, user: root, privateKeyPath: "/root/works/terraform-kb/kubesphere-libvirt/deploy/.ssh-default/id_rsa.key"}
%{ endfor }
%{ for k, v in all_nodes }
  - {name: ${k}, address: ${prefixIP}.${v.octetIP}, internalAddress: ${prefixIP}.${v.octetIP}, user: root, privateKeyPath: "/root/works/terraform-kb/kubesphere-libvirt/deploy/.ssh-default/id_rsa.key"}
%{ endfor }
%{ for k, v in worker_nodes }
  - {name: ${k}, address: ${prefixIP}.${v.octetIP}, internalAddress: ${prefixIP}.${v.octetIP}, user: root, privateKeyPath: "/root/works/terraform-kb/kubesphere-libvirt/deploy/.ssh-default/id_rsa.key"}
%{ endfor }
  roleGroups:
    etcd:
%{ for k, v in master_nodes }
    - ${k}
%{ endfor }
%{ for k, v in all_nodes }
    - ${k}
%{ endfor }
    control-plane:
%{ for k, v in master_nodes }
    - ${k}
%{ endfor }
%{ for k, v in all_nodes }
    - ${k}
%{ endfor }
    worker:
%{ for k, v in worker_nodes }
    - ${k}
%{ endfor }
%{ for k, v in all_nodes }
    - ${k}
%{ endfor }
  controlPlaneEndpoint:
    domain: lb.kubesphere.local
    address: ${master_ip}
    port: 6443
  kubernetes:
    version: ${upgrade_version}
    clusterName: cluster.local
    autoRenewCerts: true
    containerManager: containerd
  etcd:
    type: kubekey
  network:
    plugin: calico
    kubePodsCIDR: 10.233.64.0/18
    kubeServiceCIDR: 10.233.0.0/18
    multusCNI:
      enabled: false
  registry:
    privateRegistry: ""
    namespaceOverride: ""
    registryMirrors: []
    insecureRegistries: []
  addons: []
