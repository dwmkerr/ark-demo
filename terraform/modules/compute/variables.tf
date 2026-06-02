variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "disk_gb" {
  type    = number
  default = 30
}

variable "use_spot" {
  type    = bool
  default = false
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "eip_allocation_id" {
  type = string
}

variable "node_public_ip" {
  type = string
}

variable "k3s_token" {
  type      = string
  sensitive = true
}
