variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH and the k3s API (e.g. your IP/32)."
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
