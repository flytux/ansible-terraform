terraform {
  required_version = ">= 0.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.10"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0.4"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
