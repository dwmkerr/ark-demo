variable "namespace" {
  type    = string
  default = "default"
}

# Ark operator chart. Leave empty to skip (e.g. if Ark is already installed).
# TODO: set to the published Ark operator chart ref, e.g.
#   oci://ghcr.io/mckinsey/agents-at-scale-ark/ark-controller
variable "ark_chart" {
  type    = string
  default = ""
}

variable "ark_chart_version" {
  type    = string
  default = null
}

variable "ark_demo_chart_path" {
  type        = string
  description = "Path to the local ark-demo chart."
}

variable "model_api_keys" {
  type = object({
    anthropic = optional(string, "")
    gemini    = optional(string, "")
    openai    = optional(string, "")
    azure     = optional(string, "")
  })
  sensitive = true
  default   = {}
}
