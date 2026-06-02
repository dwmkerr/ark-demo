provider "aws" {
  region = var.region
}

provider "random" {}

# The kubeconfig is published to SSM by the k3s node's cloud-init. On a clean
# state apply module.network + module.compute first (see terraform/README.md),
# so this parameter holds a real kubeconfig before the providers below resolve.
data "aws_ssm_parameter" "kubeconfig" {
  name            = module.compute.kubeconfig_ssm_parameter
  with_decryption = true
}

locals {
  kubeconfig = yamldecode(data.aws_ssm_parameter.kubeconfig.value)
  cluster    = local.kubeconfig.clusters[0].cluster
  user       = local.kubeconfig.users[0].user
}

provider "kubernetes" {
  host                   = local.cluster.server
  cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
  client_certificate     = base64decode(local.user["client-certificate-data"])
  client_key             = base64decode(local.user["client-key-data"])
}

provider "helm" {
  kubernetes {
    host                   = local.cluster.server
    cluster_ca_certificate = base64decode(local.cluster["certificate-authority-data"])
    client_certificate     = base64decode(local.user["client-certificate-data"])
    client_key             = base64decode(local.user["client-key-data"])
  }
}
