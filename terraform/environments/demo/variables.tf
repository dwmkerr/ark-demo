variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH (e.g. your IP/32)."
}

variable "api_ingress_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the k3s API (6443). Open by default so CI can install; mTLS-protected."
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  type    = string
  default = "t4g.medium"
}

variable "use_spot" {
  type        = bool
  default     = false
  description = "Spot is ~3x cheaper but can be reclaimed mid-demo."
}

variable "ark_version" {
  type        = string
  default     = "0.1.63"
  description = "Ark chart version (controller/completions/tenant)."
}

variable "install_ark" {
  type        = bool
  default     = true
  description = "Install Ark (cert-manager + controller + completions + tenant). Set false if already on cluster."
}

variable "tenant_namespace" {
  type        = string
  default     = "demo"
  description = "Tenant namespace for ark-tenant RBAC and the ark-demo CRs."
}

variable "model_api_keys" {
  type = object({
    anthropic = optional(string, "")
    gemini    = optional(string, "")
    openai    = optional(string, "")
    azure     = optional(string, "")
  })
  sensitive   = true
  default     = {}
  description = "Set via TF_VAR_model_api_keys or HCP/CI variables, not in VCS."
}
