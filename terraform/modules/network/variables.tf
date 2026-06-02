variable "name" {
  type = string
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH."
}

variable "api_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the k3s API (6443). mTLS-protected; defaults open so CI runners can install. Restrict if not using CI."
  default     = ["0.0.0.0/0"]
}
