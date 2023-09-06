output "hosts" {
  # output does not support 'for_each', so use zipmap as workaround
  value = zipmap(
    values(libvirt_domain.k8s_nodes_masters)[*].name,
    values(libvirt_domain.k8s_nodes_masters)[*].vcpu
  )
}

