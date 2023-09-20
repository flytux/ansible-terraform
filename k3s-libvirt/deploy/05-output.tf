output "nodes" {
  value = zipmap(
    values(libvirt_domain.k3s_nodes)[*].name,
    values(libvirt_domain.k3s_nodes)[*].vcpu
  )
}
