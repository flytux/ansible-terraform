output "node_masters" {
  value = zipmap(
    values(libvirt_domain.k8s_nodes_masters)[*].name,
    values(libvirt_domain.k8s_nodes_masters)[*].vcpu
  )
}

output "node_workers" {
  value = zipmap(
    values(libvirt_domain.k8s_nodes_workers)[*].name,
    values(libvirt_domain.k8s_nodes_workers)[*].vcpu
  )
}
