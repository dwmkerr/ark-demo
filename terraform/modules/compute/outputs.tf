output "kubeconfig_ssm_parameter" {
  value = aws_ssm_parameter.kubeconfig.name
}

output "instance_id" {
  value = aws_instance.node.id
}

# Consumers should depend on this to ensure the cluster is reachable.
output "ready" {
  value = null_resource.wait_for_kubeconfig.id
}
