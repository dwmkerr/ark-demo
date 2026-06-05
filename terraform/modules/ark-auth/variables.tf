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

# Override the chart registry/version for ark-api + ark-dashboard only (e.g. a
# fork that publishes impersonation-capable charts the released 0.1.63 lacks).
# Empty = use ark_registry/ark_version.
variable "ark_chart_registry" {
  type    = string
  default = ""
}

variable "ark_chart_version" {
  type    = string
  default = ""
}

# Override the image the ark-dashboard chart deploys. Leave at defaults to
# use the chart's pinned upstream image; set both to test a fork-built
# branch (e.g. ghcr.io/dwmkerr/ark-dashboard:fork-build-fix-2318-<sha>).
variable "dashboard_image_repository" {
  type        = string
  default     = ""
  description = "Override repository for ark-dashboard image. Empty = use chart default."
}

variable "dashboard_image_tag" {
  type        = string
  default     = ""
  description = "Override tag for ark-dashboard image. Empty = use chart default (Chart.AppVersion)."
}

# Same override surface for ark-api — useful when testing a fork-built
# branch (e.g. the OIDC JWKS-discovery fix in #2322).
variable "ark_api_image_repository" {
  type        = string
  default     = ""
  description = "Override repository for ark-api image. Empty = use chart default."
}

variable "ark_api_image_tag" {
  type        = string
  default     = ""
  description = "Override tag for ark-api image. Empty = use chart default (Chart.AppVersion)."
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
