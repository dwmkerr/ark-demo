# Installs the Ark operator, then the local ark-demo chart on top of it.
# The helm/kubernetes providers are configured at the root from the kubeconfig
# in SSM; this module just declares releases.

# Ark operator (the runtime the ark-demo CRs need).
resource "helm_release" "ark" {
  count = var.ark_chart == "" ? 0 : 1

  name             = "ark"
  chart            = var.ark_chart
  version          = var.ark_chart_version
  namespace        = "ark-system"
  create_namespace = true
  wait             = true
}

# API keys for model providers. The chart enables a provider only when its key
# is set, mirroring the env-var behaviour in custom-values.
resource "helm_release" "ark_demo" {
  name             = "dwmkerr-ark-demo"
  chart            = var.ark_demo_chart_path
  namespace        = var.namespace
  create_namespace = true

  # Pull OCI MCP-server sub-chart dependencies before install.
  dependency_update = true

  dynamic "set_sensitive" {
    for_each = { for k, v in var.model_api_keys : k => v if v != "" }
    content {
      name  = "models.${set_sensitive.key}.apiKey"
      value = set_sensitive.value
    }
  }

  depends_on = [helm_release.ark]
}
