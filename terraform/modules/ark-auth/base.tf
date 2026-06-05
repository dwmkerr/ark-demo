# Shared contract for the ark-auth module. Other files (dex.tf, services.tf,
# tls.tf, rbac.tf) reference these locals and generated secrets — do not
# redefine hosts/secrets elsewhere.

locals {
  dashboard_host = "dashboard.${var.base_domain}"
  dex_host       = "dex.${var.base_domain}"
  api_host       = "api.${var.base_domain}"

  dashboard_url = "https://${local.dashboard_host}"
  api_url       = "https://${local.api_host}"
  dex_issuer    = "https://${local.dex_host}"

  # Static OIDC client Dex issues to the dashboard.
  dashboard_client_id = "ark-dashboard"

  # cert-manager ClusterIssuer name used by ingress annotations.
  cluster_issuer = "letsencrypt"

  # GitHub usernames are impersonated as the k8s user; this claim carries them.
  username_claim = "preferred_username"

  # ark-api/ark-dashboard chart source — fork override or the default registry.
  chart_registry = var.ark_chart_registry != "" ? var.ark_chart_registry : var.ark_registry
  chart_version  = var.ark_chart_version != "" ? var.ark_chart_version : var.ark_version
}

# Secret Dex shares with the dashboard OIDC client.
resource "random_password" "dashboard_client_secret" {
  length  = 40
  special = false
}

# NextAuth AUTH_SECRET for the dashboard session JWTs.
resource "random_password" "auth_secret" {
  length  = 40
  special = false
}
