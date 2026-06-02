variable "ark_namespace" {
  type        = string
  default     = "ark-system"
  description = "Cluster operator namespace (ark-controller, ark-completions)."
}

variable "tenant_namespace" {
  type        = string
  default     = "demo"
  description = "Tenant namespace — ark-tenant provisions its RBAC, and the ark-demo CRs live here."
}

# Set false if Ark is already installed on the cluster (skips operator + prereqs).
variable "install_ark" {
  type    = bool
  default = true
}

variable "install_cert_manager" {
  type        = bool
  default     = true
  description = "Set false if cert-manager is already present."
}

variable "cert_manager_version" {
  type    = string
  default = null # latest
}

variable "ark_registry" {
  type    = string
  default = "oci://ghcr.io/mckinsey/agents-at-scale-ark/charts"
}

variable "ark_version" {
  type    = string
  default = "0.1.63"
}

variable "ark_demo_chart_path" {
  type        = string
  description = "Path to the local ark-demo chart."
}

variable "model_api_keys" {
  type = object({
    anthropic = optional(string, "")
    gemini    = optional(string, "")
    openai    = optional(string, "")
    azure     = optional(string, "")
  })
  sensitive = true
  default   = {}
}
