# Dex bridges GitHub OAuth into OIDC for Ark: GitHub has no OIDC endpoint, so Dex
# fronts it as a standards-compliant OIDC provider. The dashboard (and the k8s API
# server) trust Dex's issuer; GitHub identity/teams flow through as OIDC claims.
resource "helm_release" "dex" {
  name             = "dex"
  repository       = "https://charts.dexidp.io"
  chart            = "dex"
  version          = "0.24.1"
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  values = [yamlencode({
    config = {
      issuer  = local.dex_issuer
      storage = { type = "memory" }
      oauth2  = { skipApprovalScreen = true }

      # GitHub is the only identity source; loadAllGroups surfaces org/team
      # membership as group claims (harmless when the user has none).
      connectors = [{
        type = "github"
        id   = "github"
        name = "GitHub"
        config = {
          clientID      = var.github_oauth_client_id
          clientSecret  = var.github_oauth_client_secret
          redirectURI   = "${local.dex_issuer}/callback"
          loadAllGroups = true
          scopes        = ["user:email", "read:org"]
        }
      }]

      staticClients = [{
        id           = local.dashboard_client_id
        name         = "ARK Dashboard"
        secret       = random_password.dashboard_client_secret.result
        redirectURIs = ["${local.dashboard_url}/api/auth/callback/dex"]
      }]

      # No local users: GitHub is the sole login path.
      enablePasswordDB = false
    }

    # Serve HTTPS behind Traefik; cert-manager provisions the dex-tls cert.
    ingress = {
      enabled     = true
      className   = "traefik"
      annotations = { "cert-manager.io/cluster-issuer" = local.cluster_issuer }
      hosts = [{
        host  = local.dex_host
        paths = [{ path = "/", pathType = "Prefix" }]
      }]
      tls = [{
        secretName = "dex-tls"
        hosts      = [local.dex_host]
      }]
    }
  })]
}
