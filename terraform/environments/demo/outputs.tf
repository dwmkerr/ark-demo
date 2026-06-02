output "node_public_ip" {
  value = module.network.eip_public_ip
}

output "kubeconfig_command" {
  description = "Pull the kubeconfig locally to talk to the cluster."
  value       = "aws ssm get-parameter --name ${module.compute.kubeconfig_ssm_parameter} --with-decryption --region ${var.region} --query Parameter.Value --output text > kubeconfig.yaml && export KUBECONFIG=$PWD/kubeconfig.yaml"
}

output "demo_release" {
  value = module.ark.release_name
}
