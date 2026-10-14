variable "image_path" {
  description = "Base qcow2 image"
  type        = string
}

variable "network_name" {
  description = "vm network"
  type        = string
}

variable "nodes" {
  description = "List of node names with network configurations"
  type = list(object({
    name = string
    mac  = string
    ip   = string
  }))
}

variable "vcpu" {
  type    = number
  default = 2
}

variable "memory" {
  description = "MiB"
  type        = number
  default     = 2048
}

variable "disk_size" {
  description = "Bytes"
  type        = number
  default     = 20 * 1024 * 1024 * 1024
}
