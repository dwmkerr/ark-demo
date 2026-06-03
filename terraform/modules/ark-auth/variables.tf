variable "ark_namespace" {
  type        = string
  default     = "ark-system"
  description = "Namespace for ark operator + ark-api/ark-dashboard."
}

variable "tenant_namespace" {
  type        = string
  default     = "demo"
  description = "Tenant namespace the demo CRs live in and users get RBAC on."
}

variable "base_domain" {
  type        = string
  description = "Base domain for the demo hosts, e.g. 34.253.157.189.nip.io."
}

variable "acme_email" {
  type        = string
  description = "Email for Let's Encrypt registration."
}

variable "ark_registry" {
  type    = string
  default = "oci://ghcr.io/mckinsey/agents-at-scale-ark/charts"
}

variable "ark_version" {
  type    = string
  default = "0.1.63"
}

variable "github_oauth_client_id" {
  type        = string
  sensitive   = true
  description = "GitHub OAuth App client id (Dex GitHub connector)."
}

variable "github_oauth_client_secret" {
  type        = string
  sensitive   = true
  description = "GitHub OAuth App client secret (Dex GitHub connector)."
}

# Allowlist: who can use the demo and at what role. A GitHub user not listed
# authenticates but gets no RBAC. role is one of: viewer | editor | admin.
variable "demo_users" {
  type = list(object({
    github = string
    role   = string
  }))
  default     = []
  description = "Per-GitHub-user role allowlist."
}
