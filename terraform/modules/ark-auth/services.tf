# ark-api + ark-dashboard with GitHub-via-Dex SSO.
#
# Both charts render env by ranging over app.env (a list). Setting entries by
# index (--set app.env[N]) pads missing indices with null and crashes the
# template (nil .name), so we supply the COMPLETE env list via values and
# override only the two secrets by their (now stable) index with set_sensitive.

resource "helm_release" "ark_api" {
  name             = "ark-api"
  repository       = var.ark_registry
  chart            = "ark-api"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  values = [yamlencode({
    app = {
      env = [
        { name = "CORS_ORIGINS", value = "*" },
        { name = "OIDC_ISSUER_URL", value = local.dex_issuer },
        { name = "OIDC_APPLICATION_ID", value = local.dashboard_client_id },
        { name = "AUTH_MODE", value = "sso" },
        { name = "PROXY_TIMEOUT", value = "10.0" },
        { name = "ARK_A2A_AGENT_CARD_PORT", value = "443" },
        { name = "ARK_A2A_AGENT_CARD_HOST", value = local.api_host },
        { name = "ARK_A2A_AGENT_CARD_PROTOCOL", value = "https" },
        { name = "READ_ONLY_MODE", value = "false" },
      ]
    }
    # Impersonate the authenticated GitHub user (preferred_username) so k8s RBAC
    # applies per user.
    impersonation = {
      enabled       = true
      fallback      = false
      usernameClaim = local.username_claim
      groupsClaim   = "groups"
    }
    ingress = {
      enabled     = true
      className   = "traefik"
      annotations = { "cert-manager.io/cluster-issuer" = local.cluster_issuer }
      hosts       = [{ host = local.api_host, paths = [{ path = "/", pathType = "Prefix" }] }]
      tls         = [{ secretName = "ark-api-tls", hosts = [local.api_host] }]
    }
  })]
}

resource "helm_release" "ark_dashboard" {
  name             = "ark-dashboard"
  repository       = var.ark_registry
  chart            = "ark-dashboard"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  values = [yamlencode({
    app = {
      # Dashboard proxies to ark-api in-cluster (same namespace).
      config = {
        arkApiService = { host = "ark-api", port = "80", protocol = "http" }
      }
      env = [
        { name = "BASE_URL", value = local.dashboard_url },                      # 0
        { name = "AUTH_URL", value = "${local.dashboard_url}/api/auth" },        # 1
        { name = "AUTH_SECRET", value = "" },                                    # 2 (set_sensitive)
        { name = "OIDC_ISSUER_URL", value = local.dex_issuer },                  # 3
        { name = "OIDC_CLIENT_ID", value = local.dashboard_client_id },          # 4
        { name = "OIDC_CLIENT_SECRET", value = "" },                             # 5 (set_sensitive)
        { name = "OIDC_PROVIDER_NAME", value = "GitHub" },                       # 6
        { name = "OIDC_PROVIDER_ID", value = "dex" },                            # 7
        { name = "SESSION_MAX_AGE", value = "1800" },                            # 8
        { name = "NEXT_PUBLIC_TOKEN_REFRESH_INTERVAL_MS", value = "600000" },    # 9
        { name = "NEXT_PUBLIC_FALLBACK_INACTIVITY_TIMEOUT", value = "1800000" }, # 10
        { name = "AUTH_MODE", value = "sso" },                                   # 11
      ]
    }
    ingress = {
      enabled     = true
      className   = "traefik"
      annotations = { "cert-manager.io/cluster-issuer" = local.cluster_issuer }
      hosts       = [{ host = local.dashboard_host, paths = [{ path = "/", pathType = "Prefix" }] }]
      tls         = [{ secretName = "ark-dashboard-tls", hosts = [local.dashboard_host] }]
    }
  })]

  # Secrets injected over the (stable) list indices, kept out of plan output.
  set_sensitive {
    name  = "app.env[2].value"
    value = random_password.auth_secret.result
  }
  set_sensitive {
    name  = "app.env[5].value"
    value = random_password.dashboard_client_secret.result
  }

  depends_on = [helm_release.ark_api]
}
