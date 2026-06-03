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

# Covers EC2/VPC/SSM/etc, but explicitly NOT IAM.
resource "aws_iam_role_policy_attachment" "power" {
  role       = aws_iam_role.ci.name
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

# PowerUserAccess excludes IAM, but the compute module manages the node's role
# and instance profile. Grant just those IAM actions, scoped to ark-demo-* names.
data "aws_iam_policy_document" "ci_iam" {
  statement {
    sid = "ManageDemoNodeIAM"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:CreateInstanceProfile",
      "iam:DeleteInstanceProfile",
      "iam:GetInstanceProfile",
      "iam:AddRoleToInstanceProfile",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:TagInstanceProfile",
      "iam:ListInstanceProfileTags",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ark-demo-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/ark-demo-*",
    ]
  }

  statement {
    sid       = "PassDemoNodeRole"
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ark-demo-*"]
  }
}

resource "aws_iam_role_policy" "ci_iam" {
  name   = "ark-demo-ci-iam"
  role   = aws_iam_role.ci.id
  policy = data.aws_iam_policy_document.ci_iam.json
}
