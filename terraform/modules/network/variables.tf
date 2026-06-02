variable "name" {
  type = string
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH and the k3s API."
}
