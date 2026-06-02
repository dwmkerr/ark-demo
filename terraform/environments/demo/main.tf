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

  ark_demo_chart_path = "${path.module}/../../../chart"
  ark_version         = var.ark_version
  install_ark         = var.install_ark
  model_api_keys      = var.model_api_keys

  # Don't install onto the cluster until cloud-init has it ready.
  depends_on = [module.compute]
}
