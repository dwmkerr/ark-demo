# Bootstrap: run ONCE, manually, with admin-ish local credentials.
# Creates the GitHub Actions OIDC provider and the IAM role the pipeline assumes.
# Kept separate from the demo environment because it has a different lifecycle
# (created once, rarely changed) and resolves the chicken-and-egg of OIDC auth.

terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

# Only one OIDC provider per URL is allowed per account, and it is often shared
# across repos. Reference the existing one rather than managing (and on destroy,
# deleting) it. If it does not exist yet, create it once out-of-band.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Restrict to this repo. Covers PR plan and main apply.
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

resource "aws_iam_role" "ci" {
  name               = "ark-demo-terraform-ci"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

# Demo scope — broad enough to manage EC2/VPC/SSM/IAM-passrole for the env.
# Tighten before any non-demo use.
resource "aws_iam_role_policy_attachment" "power" {
  role       = aws_iam_role.ci.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}
