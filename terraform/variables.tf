variable "image_path" {
  description = "Path for base qcow2 image"
  type        = string
}

variable "network_name" {
  description = "Name of common libvirt network"
  type        = string
  default     = "ha-net"
}

variable "network_domain" {
  description = "top level dns for dnsmasq"
  type        = string
  default     = "ha.local"
}
