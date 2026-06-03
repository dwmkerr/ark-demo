# cert-manager ClusterIssuer for Let's Encrypt. cert-manager is installed
# separately; its CRDs must already exist (kubernetes_manifest runs a
# server-side dry-run at plan time, so the cluster must be reachable).
#
# HTTP-01 challenges require port 80 on the ingress to be reachable from the
# public internet so Let's Encrypt can validate domain ownership (the demo
# security group already allows 80).
#
# For testing, swap server to the LE staging endpoint to avoid hitting the
# strict production rate limits:
#   https://acme-staging-v02.api.letsencrypt.org/directory
resource "kubernetes_manifest" "cluster_issuer" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = local.cluster_issuer
    }
    spec = {
      # email is optional for Let's Encrypt; omit it entirely when not set so no
      # contact address is registered.
      acme = merge(
        {
          server = "https://acme-v02.api.letsencrypt.org/directory"
          privateKeySecretRef = {
            name = "letsencrypt-account-key"
          }
          solvers = [
            {
              http01 = {
                ingress = {
                  class = "traefik"
                }
              }
            },
          ]
        },
        var.acme_email == "" ? {} : { email = var.acme_email },
      )
    }
  }
}
