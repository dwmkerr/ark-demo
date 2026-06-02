terraform {
  required_version = ">= 1.10"

  # HCP Terraform (app.terraform.io) free tier — remote state, locking, runs.
  # Create the org + workspace in the UI, then `terraform login`.
  cloud {
    organization = "dwmkerr"

    workspaces {
      name = "ark-demo"
    }
  }

  # --- Alternative: keep state in AWS (no HCP). Comment out the cloud block
  # above and uncomment this. Native S3 lockfile needs Terraform >= 1.10.
  # backend "s3" {
  #   bucket       = "CHANGE-ME-tfstate"
  #   key          = "ark-demo/demo.tfstate"
  #   region       = "eu-west-1"
  #   encrypt      = true
  #   use_lockfile = true
  # }

  required_providers {
    aws        = { source = "hashicorp/aws", version = "~> 5.0" }
    helm       = { source = "hashicorp/helm", version = "~> 2.13" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.30" }
    random     = { source = "hashicorp/random", version = "~> 3.6" }
  }
}
