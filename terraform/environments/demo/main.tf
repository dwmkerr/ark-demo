locals {
  name = "ark-demo"
}

# Stable join token for k3s so node replacement doesn't invalidate the cluster.
resource "random_password" "k3s_token" {
  length  = 48
  special = false
}

module "network" {
  source            = "../../modules/network"
  name              = local.name
  admin_cidrs       = var.admin_cidrs
  api_ingress_cidrs = var.api_ingress_cidrs
}

module "compute" {
  source = "../../modules/compute"

  name              = local.name
  region            = var.region
  instance_type     = var.instance_type
  use_spot          = var.use_spot
  subnet_id         = module.network.subnet_id
  security_group_id = module.network.security_group_id
  eip_allocation_id = module.network.eip_allocation_id
  node_public_ip    = module.network.eip_public_ip
  k3s_token         = random_password.k3s_token.result
}

module "ark" {
  source = "../../modules/ark"

  ark_demo_chart_path   = "${path.module}/../../../chart"
  ark_demo_values_files = ["${path.module}/ark-demo-values.yaml"]
  ark_version           = var.ark_version
  install_ark           = var.install_ark
  tenant_namespace      = var.tenant_namespace
  model_api_keys        = var.model_api_keys

  # Don't install onto the cluster until cloud-init has it ready.
  depends_on = [module.compute]
}

# GitHub SSO via Dex + ark-api/ark-dashboard + per-user RBAC. Off by default so
# the base demo runs without a GitHub OAuth App / DNS / TLS; flip enable_sso on
# once those are ready.
# Stable DNS: a wildcard A record for the demo subdomain pointing at the current
# EIP. Survives destroy/apply (the EIP may change; this record is updated), so
# the GitHub OAuth App callback (https://dex.<subdomain>/callback) never changes.
data "aws_route53_zone" "demo" {
  count = var.enable_sso ? 1 : 0
  name  = var.dns_zone
}

resource "aws_route53_record" "demo_wildcard" {
  count   = var.enable_sso ? 1 : 0
  zone_id = data.aws_route53_zone.demo[0].zone_id
  name    = "*.${var.subdomain}"
  type    = "A"
  ttl     = 60
  records = [module.network.eip_public_ip]
}

module "ark_auth" {
  count  = var.enable_sso ? 1 : 0
  source = "../../modules/ark-auth"

  tenant_namespace           = var.tenant_namespace
  base_domain                = var.subdomain
  acme_email                 = var.acme_email
  ark_version                = var.ark_version
  github_oauth_client_id     = var.github_oauth_client_id
  github_oauth_client_secret = var.github_oauth_client_secret
  demo_users                 = var.demo_users
  dashboard_image_repository = var.dashboard_image_repository
  dashboard_image_tag        = var.dashboard_image_tag
  ark_api_image_repository   = var.ark_api_image_repository
  ark_api_image_tag          = var.ark_api_image_tag

  # Needs cert-manager + the Ark operator present, and DNS resolving for the
  # Let's Encrypt HTTP-01 challenge.
  depends_on = [module.ark, aws_route53_record.demo_wildcard]
}
