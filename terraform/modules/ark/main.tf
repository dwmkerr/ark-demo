# Installs Ark, then the local ark-demo chart on top.
# Recipe mirrors the Ark e2e setup / ark-cli (agents-at-scale-ark):
#   cert-manager -> ark-controller -> ark-completions -> ark-tenant -> ark-demo
# Default storage backend is etcd (CRDs) — no external database needed.
# The helm/kubernetes providers are configured at the root from the kubeconfig
# in SSM; this module only declares releases.

# cert-manager — REQUIRED: ark-controller has certmanager.enable=true by default
# and injects CA into its webhooks. wait=true so the webhook is ready first.
resource "helm_release" "cert_manager" {
  count = var.install_ark && var.install_cert_manager ? 1 : 0

  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

# ark-controller — the operator that reconciles Model/Agent/Team/MCP CRs.
resource "helm_release" "ark_controller" {
  count = var.install_ark ? 1 : 0

  name             = "ark-controller"
  repository       = var.ark_registry
  chart            = "ark-controller"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  set {
    name  = "rbac.enable"
    value = "true"
  }

  depends_on = [helm_release.cert_manager]
}

# ark-completions — mandatory; the controller calls it at
# http://ark-completions.ark-system.
resource "helm_release" "ark_completions" {
  count = var.install_ark ? 1 : 0

  name             = "ark-completions"
  repository       = var.ark_registry
  chart            = "ark-completions"
  version          = var.ark_version
  namespace        = var.ark_namespace
  create_namespace = true
  wait             = true

  depends_on = [helm_release.ark_controller]
}

# ark-tenant — installs INTO the tenant namespace, creating its service account,
# RBAC, and quota. The controller impersonates this SA to reconcile tenant CRs.
resource "helm_release" "ark_tenant" {
  count = var.install_ark ? 1 : 0

  name             = "ark-tenant"
  repository       = var.ark_registry
  chart            = "ark-tenant"
  version          = var.ark_version
  namespace        = var.tenant_namespace
  create_namespace = true
  wait             = true

  depends_on = [helm_release.ark_completions]
}

# The ark-demo chart (this repo): Models/Agents/Teams/MCP CRs. A provider's key
# is set only when supplied, mirroring the chart's env-var enable behaviour.
resource "helm_release" "ark_demo" {
  name      = "dwmkerr-ark-demo"
  chart     = var.ark_demo_chart_path
  namespace = var.tenant_namespace
  # ark-tenant already created and owns the namespace.
  create_namespace = false

  # The chart ships no values.yaml; supply the full structure from a file.
  values = [for f in var.ark_demo_values_files : file(f)]

  # NOTE: the helm provider panics resolving OCI chart dependencies
  # (dependency_update=true -> nil registry client). Build deps with the helm
  # CLI before terraform runs (see the terraform workflows / 'make install').
  dependency_update = false

  dynamic "set_sensitive" {
    for_each = { for k, v in var.model_api_keys : k => v if v != "" }
    content {
      name  = "models.${set_sensitive.key}.apiKey"
      value = set_sensitive.value
    }
  }

  depends_on = [helm_release.ark_tenant]
}
