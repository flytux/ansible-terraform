output "k8s_nodes" {
  value = zipmap(
    values(libvirt_domain.k8s_nodes)[*].name,
    values(libvirt_domain.k8s_nodes)[*].vcpu
  )
}

