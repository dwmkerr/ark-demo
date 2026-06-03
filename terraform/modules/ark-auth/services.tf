# ark-api and ark-dashboard, wired to Dex for SSO. Both charts inject env vars
# from the app.env LIST, so values are set positionally by array index; we set
# both .name and .value at each index so the override is self-describing and
# does not depend on the chart's default ordering staying stable.

# ark-api — FastAPI backend. SSO validates Dex-issued JWTs; impersonation makes
# RBAC apply to the GitHub user (via preferred_username) rather than the SA.
resource "helm_release" "ark_api" {
  name             = "ark-api"
  repository       = var.ark_registry
  chart            = "ark-api"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  # Auth env (app.env list): [1]=OIDC_ISSUER_URL, [2]=OIDC_APPLICATION_ID,
  # [3]=AUTH_MODE in the chart's default values.yaml.
  set {
    name  = "app.env[1].name"
    value = "OIDC_ISSUER_URL"
  }
  set {
    name  = "app.env[1].value"
    value = local.dex_issuer
  }
  set {
    name  = "app.env[2].name"
    value = "OIDC_APPLICATION_ID"
  }
  set {
    name  = "app.env[2].value"
    value = local.dashboard_client_id
  }
  set {
    name  = "app.env[3].name"
    value = "AUTH_MODE"
  }
  set {
    name  = "app.env[3].value"
    value = "sso"
  }

  # Impersonation block — own top-level keys, not part of app.env.
  set {
    name  = "impersonation.enabled"
    value = "true"
  }
  set {
    name  = "impersonation.usernameClaim"
    value = local.username_claim
  }
  set {
    name  = "impersonation.groupsClaim"
    value = "groups"
  }

  # Ingress (traefik + cert-manager TLS via the letsencrypt ClusterIssuer).
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.className"
    value = "traefik"
  }
  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = local.cluster_issuer
  }
  set {
    name  = "ingress.hosts[0].host"
    value = local.api_host
  }
  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }
  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "ark-api-tls"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.api_host
  }
}

# ark-dashboard — Next.js UI. NextAuth handles the OIDC code flow against Dex,
# then calls ark-api in-cluster. The dashboard targets ark-api via the discrete
# app.config.arkApiService.{host,port,protocol} keys (chart has no single URL
# value); defaults are host=ark-api, port=80, protocol=http.
resource "helm_release" "ark_dashboard" {
  name             = "ark-dashboard"
  repository       = var.ark_registry
  chart            = "ark-dashboard"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  # In-cluster ark-api target (Service is named ark-api on port 80).
  set {
    name  = "app.config.arkApiService.host"
    value = "ark-api.${var.ark_namespace}"
  }
  set {
    name  = "app.config.arkApiService.port"
    value = "80"
  }
  set {
    name  = "app.config.arkApiService.protocol"
    value = "http"
  }

  # Auth env (app.env list): [0]=BASE_URL, [1]=AUTH_URL, [2]=AUTH_SECRET,
  # [3]=OIDC_ISSUER_URL, [4]=OIDC_CLIENT_ID, [5]=OIDC_CLIENT_SECRET,
  # [6]=OIDC_PROVIDER_NAME, [7]=OIDC_PROVIDER_ID, [10]=AUTH_MODE.
  set {
    name  = "app.env[0].name"
    value = "BASE_URL"
  }
  set {
    name  = "app.env[0].value"
    value = local.dashboard_url
  }
  set {
    name  = "app.env[1].name"
    value = "AUTH_URL"
  }
  set {
    name  = "app.env[1].value"
    value = "${local.dashboard_url}/api/auth"
  }
  set {
    name  = "app.env[2].name"
    value = "AUTH_SECRET"
  }
  set_sensitive {
    name  = "app.env[2].value"
    value = random_password.auth_secret.result
  }
  set {
    name  = "app.env[3].name"
    value = "OIDC_ISSUER_URL"
  }
  set {
    name  = "app.env[3].value"
    value = local.dex_issuer
  }
  set {
    name  = "app.env[4].name"
    value = "OIDC_CLIENT_ID"
  }
  set {
    name  = "app.env[4].value"
    value = local.dashboard_client_id
  }
  set {
    name  = "app.env[5].name"
    value = "OIDC_CLIENT_SECRET"
  }
  set_sensitive {
    name  = "app.env[5].value"
    value = random_password.dashboard_client_secret.result
  }
  set {
    name  = "app.env[6].name"
    value = "OIDC_PROVIDER_NAME"
  }
  set {
    name  = "app.env[6].value"
    value = "GitHub"
  }
  set {
    name  = "app.env[7].name"
    value = "OIDC_PROVIDER_ID"
  }
  set {
    name  = "app.env[7].value"
    value = "dex"
  }
  set {
    name  = "app.env[10].name"
    value = "AUTH_MODE"
  }
  set {
    name  = "app.env[10].value"
    value = "sso"
  }

  # Ingress (traefik + cert-manager TLS via the letsencrypt ClusterIssuer).
  set {
    name  = "ingress.enabled"
    value = "true"
  }
  set {
    name  = "ingress.className"
    value = "traefik"
  }
  set {
    name  = "ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = local.cluster_issuer
  }
  set {
    name  = "ingress.hosts[0].host"
    value = local.dashboard_host
  }
  set {
    name  = "ingress.hosts[0].paths[0].path"
    value = "/"
  }
  set {
    name  = "ingress.hosts[0].paths[0].pathType"
    value = "Prefix"
  }
  set {
    name  = "ingress.tls[0].secretName"
    value = "ark-dashboard-tls"
  }
  set {
    name  = "ingress.tls[0].hosts[0]"
    value = local.dashboard_host
  }

  depends_on = [helm_release.ark_api]
}
