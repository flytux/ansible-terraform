terraform {
  required_version = ">= 0.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.6"
    }
  }
}

# instance of the provider
provider "libvirt" {
  # ensures system connection, not userspace qemu:///session
  uri = "qemu:///system"
}
