output "ci_role_arn" {
  description = "Set this as the role-to-assume in the GitHub Actions workflows."
  value       = aws_iam_role.ci.arn
}
