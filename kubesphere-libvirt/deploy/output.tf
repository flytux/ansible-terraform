output "node_masters" {
  value = zipmap(
    values(libvirt_domain.k8s_nodes)[*].name,
    values(libvirt_domain.k8s_nodes)[*].vcpu
  )
}

output "node_workers" {
  value = zipmap(
    values(libvirt_domain.k8s_nodes)[*].name,
    values(libvirt_domain.k8s_nodes)[*].vcpu
  )
}
