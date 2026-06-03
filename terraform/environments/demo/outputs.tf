output "node_public_ip" {
  value = module.network.eip_public_ip
}

output "kubeconfig_command" {
  description = "Direct access (CI / off-proxy networks). Pulls the EIP kubeconfig."
  value       = "aws ssm get-parameter --name ${module.compute.kubeconfig_ssm_parameter} --with-decryption --region ${var.region} --query Parameter.Value --output text > kubeconfig.yaml && export KUBECONFIG=$PWD/kubeconfig.yaml"
}

# Laptop access from a TLS-inspecting corporate network: tunnel via SSM (rides
# the AWS channel, so the proxy never sees the cluster's mTLS). Needs the AWS
# session-manager-plugin installed locally.
output "laptop_access" {
  description = "Access from a corp network via SSM port-forward (run the two commands in separate shells)."
  value       = <<-EOT
    # 1. Pull the local kubeconfig (server stays 127.0.0.1:6443):
    aws ssm get-parameter --name ${module.compute.kubeconfig_local_ssm_parameter} --with-decryption --region ${var.region} --query Parameter.Value --output text > kubeconfig.yaml
    export KUBECONFIG=$PWD/kubeconfig.yaml

    # 2. In another shell, open the tunnel (leave running):
    aws ssm start-session --target ${module.compute.instance_id} --region ${var.region} \
      --document-name AWS-StartPortForwardingSession \
      --parameters '{"portNumber":["6443"],"localPortNumber":["6443"]}'

    # 3. Back in shell 1: kubectl get models,agents,teams -A
  EOT
}

output "node_instance_id" {
  value = module.compute.instance_id
}

output "region" {
  value = var.region
}

output "tenant_namespace" {
  value = var.tenant_namespace
}

output "demo_release" {
  value = module.ark.release_name
}

output "sso_dashboard_url" {
  description = "Dashboard URL when SSO is enabled."
  value       = try(module.ark_auth[0].dashboard_url, null)
}

output "github_oauth_callback_url" {
  description = "Set this as the GitHub OAuth App's Authorization callback URL."
  value       = try(module.ark_auth[0].github_oauth_callback_url, null)
}
