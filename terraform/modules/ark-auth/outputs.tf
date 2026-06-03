output "dashboard_url" {
  value = local.dashboard_url
}

output "dex_issuer" {
  value = local.dex_issuer
}

# The GitHub OAuth App's Authorization callback URL must be set to this.
output "github_oauth_callback_url" {
  value = "${local.dex_issuer}/callback"
}

output "hosts" {
  value = {
    dashboard = local.dashboard_host
    dex       = local.dex_host
    api       = local.api_host
  }
}
