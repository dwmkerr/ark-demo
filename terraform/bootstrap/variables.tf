variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "github_repo" {
  type        = string
  description = "owner/name of the repo allowed to assume the CI role."
  default     = "dwmkerr/ark-demo"
}
