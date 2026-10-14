terraform {
  required_version = ">= 1.5"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.9.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  control-plane-nodes = [
    { name = "control-plane-01", mac = "52:54:00:01:01:00", ip = "10.10.10.11" },
    { name = "control-plane-02", mac = "52:54:00:01:02:00", ip = "10.10.10.12" },
    { name = "control-plane-03", mac = "52:54:00:01:03:00", ip = "10.10.10.13" },
  ]

  worker-nodes = [
    { name = "worker-01", mac = "52:54:00:02:01:00", ip = "10.10.10.21" },
    { name = "worker-02", mac = "52:54:00:02:02:00", ip = "10.10.10.22" },
    { name = "worker-03", mac = "52:54:00:02:03:00", ip = "10.10.10.23" },
  ]

  all_nodes = concat(local.control-plane-nodes, local.worker-nodes)
}

resource "libvirt_network" "ha" {
  name      = var.network_name
  autostart = true

  forward = {
    mode = "nat"
  }

  domain = {
    name       = var.network_domain
    local_only = "yes"
  }

  dns = {
    host = [
      for node in local.all_nodes : {
        ip = node.ip
        hostnames = [
          { hostname = node.name },
          { hostname = "${node.name}.${var.network_domain}" },
        ]
      }
    ]
  }

  ips = [
    {
      address = "10.10.10.1"
      prefix  = 24

      dhcp = {
        # lease static
        hosts = [
          for node in local.all_nodes : {
            mac  = node.mac
            ip   = node.ip
            name = node.name
          }
        ]

        # dncp
        ranges = [
          { start = "10.10.10.100", end = "10.10.10.254" }
        ]
      }
    }
  ]
}

module "control-plane" {
  source = "./modules/libvirt-vms"

  image_path   = var.image_path
  network_name = libvirt_network.ha.name
  nodes        = local.control-plane-nodes

  vcpu      = 2
  memory    = 2048
  disk_size = 20 * 1024 * 1024 * 1024
}

module "worker" {
  source = "./modules/libvirt-vms"

  image_path   = var.image_path
  network_name = libvirt_network.ha.name
  nodes        = local.worker-nodes

  vcpu      = 2
  memory    = 2048
  disk_size = 20 * 1024 * 1024 * 1024
}
