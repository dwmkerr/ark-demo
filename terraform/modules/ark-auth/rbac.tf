# Namespace-scoped RBAC for demo users.
#
# Authentication (who you are) is handled by Dex + GitHub upstream; the GitHub
# login arrives as the impersonated k8s user via the preferred_username claim
# (see local.username_claim in base.tf). This file handles authorization (what
# you can do) inside var.tenant_namespace only.
#
# Soft gate: a GitHub user who is NOT in var.demo_users can still authenticate
# through Dex, but has no RoleBinding created here and therefore gets zero
# permissions in the tenant namespace. Access is granted purely by listing the
# user in var.demo_users with a role of viewer | editor | admin.
#
# Three Roles map to those values: ark-viewer, ark-editor, ark-admin. The
# RoleBinding for each user references "ark-${role}".
#
# Native kubernetes_role / kubernetes_role_binding resources are used (rather
# than kubernetes_manifest) so the plan does not depend on the Ark CRDs being
# installed at plan time.

locals {
  # Ark custom resources live in the ark.mckinsey.com API group. These plurals
  # are taken verbatim from the Ark CRDs (spec.names.plural) in
  # mckinsey/agents-at-scale-ark: ark/config/crd/bases/ark.mckinsey.com_*.yaml.
  ark_api_group = "ark.mckinsey.com"
}

# ark-viewer: read-only across all Ark resources, plus pod/log visibility so
# users can inspect query run output.
resource "kubernetes_role" "ark_viewer" {
  metadata {
    name      = "ark-viewer"
    namespace = var.tenant_namespace
  }

  rule {
    api_groups = [local.ark_api_group]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "events", "services"]
    verbs      = ["get", "list", "watch"]
  }
}

# ark-editor: everything a viewer can do, plus full lifecycle on queries
# (running agents/teams) and authoring of agents, teams and tools. Deletion is
# only granted on queries; authored resources can be created/updated but not
# deleted by an editor.
resource "kubernetes_role" "ark_editor" {
  metadata {
    name      = "ark-editor"
    namespace = var.tenant_namespace
  }

  rule {
    api_groups = [local.ark_api_group]
    resources  = ["*"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "events", "services"]
    verbs      = ["get", "list", "watch"]
  }

  # Running agents/teams is done by creating Query resources.
  rule {
    api_groups = [local.ark_api_group]
    resources  = ["queries"]
    verbs      = ["create", "update", "patch", "delete"]
  }

  rule {
    api_groups = [local.ark_api_group]
    resources  = ["agents", "teams", "tools"]
    verbs      = ["create", "update", "patch"]
  }
}

# ark-admin: full control of all Ark resources in the namespace, plus read
# access to the pods, logs, events, configmaps and secrets backing them.
resource "kubernetes_role" "ark_admin" {
  metadata {
    name      = "ark-admin"
    namespace = var.tenant_namespace
  }

  rule {
    api_groups = [local.ark_api_group]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "events", "configmaps", "secrets", "services"]
    verbs      = ["get", "list", "watch"]
  }
}

# One RoleBinding per allowlisted user, keyed by GitHub username. The bound
# subject name is the GitHub login (impersonated user); the bound Role is
# selected by the user's role value.
resource "kubernetes_role_binding" "ark_user" {
  for_each = { for u in var.demo_users : u.github => u }

  metadata {
    name      = "ark-user-${each.value.github}"
    namespace = var.tenant_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "ark-${each.value.role}"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = each.value.github
  }
}
