output "release_name" {
  value = helm_release.ark_demo.name
}

output "namespace" {
  value = helm_release.ark_demo.namespace
}
