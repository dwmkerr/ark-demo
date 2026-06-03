variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "admin_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach SSH (e.g. your IP/32). Empty = no SSH; use SSM."
  default     = []
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

# --- GitHub SSO (Dex + ark-dashboard/api + per-user RBAC) ---

variable "enable_sso" {
  type        = bool
  default     = false
  description = "Install Dex GitHub SSO + ark-dashboard/api + RBAC. Needs a GitHub OAuth App, the vars below, and ports 80/443 reachable for TLS."
}

variable "dns_zone" {
  type        = string
  default     = "dwmkerr.com"
  description = "Route53 hosted zone for the demo subdomain."
}

variable "subdomain" {
  type        = string
  default     = "ark-demo.dwmkerr.com"
  description = "Stable subdomain for the demo. Hosts dashboard/dex/api.<subdomain> resolve here via a wildcard A record to the EIP."
}

variable "acme_email" {
  type        = string
  default     = ""
  description = "Email for Let's Encrypt registration (required when enable_sso)."
}

variable "github_oauth_client_id" {
  type        = string
  default     = ""
  sensitive   = true
  description = "GitHub OAuth App client id (required when enable_sso)."
}

variable "github_oauth_client_secret" {
  type        = string
  default     = ""
  sensitive   = true
  description = "GitHub OAuth App client secret (required when enable_sso)."
}

variable "demo_users" {
  type = list(object({
    github = string
    role   = string
  }))
  default     = []
  description = "Per-GitHub-user role allowlist: role is viewer | editor | admin."
}

# Override the image the ark-dashboard chart deploys. Leave empty to use
# the chart's pinned upstream image; set both to test a fork-built branch
# (e.g. ghcr.io/dwmkerr/ark-dashboard:fork-build-fix-2318-d591a69).
variable "dashboard_image_repository" {
  type        = string
  default     = ""
  description = "Override repository for ark-dashboard image. Empty = chart default."
}

variable "dashboard_image_tag" {
  type        = string
  default     = ""
  description = "Override tag for ark-dashboard image. Empty = chart default."
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
