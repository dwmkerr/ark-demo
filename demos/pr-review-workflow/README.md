# pr-review-workflow

This workflow reviews all requests in a GitHub repository.

## Installation

See [Argo Workflows documentation](https://mckinsey.github.io/agents-at-scale-ark/developer-guide/workflows/argo-workflows) for full details.

```bash
# Install Argo Workflows for ARK
helm upgrade --install argo-workflows \
  oci://ghcr.io/mckinsey/agents-at-scale-ark/charts/argo-workflows

# Create a PVC to use as a shared workspace.
kubectl apply -f ./workspace-pvc.yaml

# Install the shell MCP server with workspace PVC mounted.
helm install shell-mcp oci://ghcr.io/dwmkerr/charts/shell-mcp \
  --set volumes[0].name=workspace \
  --set volumes[0].persistentVolumeClaim.claimName=github-mcp-workspace \
  --set volumeMounts[0].name=workspace \
  --set volumeMounts[0].mountPath=/workspace

# Install the GitHub MCP server.
helm install github-mcp oci://ghcr.io/dwmkerr/charts/github-mcp \
  --set github.token="$GITHUB_TOKEN"

# Create the PR review agent with all GitHub and shell tools
kubectl apply -f ./pr-review-agent.yaml

# Create the workflow template.
kubectl apply -f ./pr-review-workflow.yaml

# To run the workflow, option 1 is to use the argo cli:
argo submit --from workflowtemplate/pr-review-workflow \
    -p github-org=mckinsey \
    -p github-repo=agents-at-scale-ark \
    --watch

# Option 2 is to use the UI. If you are using `devspace dev` for
# `ark-workflows` this port is automatically forwarded.
kubectl port-forward 2746:2746 &
open http://localhost:2746
```

## Artifact Storage

Argo can store artifacts to any S3 backend. To enable [Minio as an Artifact Repository](https://argo-workflows.readthedocs.io/en/latest/configure-artifact-repository/#configuring-minio):

```bash
# Install the minio operator.
helm repo add minio https://charts.min.io/ # official minio Helm charts
helm repo update

# Install the minio tenant.
helm upgrade --install minio-tenant minio-operator/tenant

# Get the username / password. Defaults to:
# Username: minio
# Password: minio123
username="$(kubectl get secret myminio-env-configuration \
    -o jsonpath='{.data.config\.env}' | base64 -d |\
    grep MINIO_ROOT_USER | cut -d'"' -f2)"
password="$(kubectl get secret myminio-env-configuration \
    -o jsonpath='{.data.config\.env}' | base64 -d |\
    grep MINIO_ROOT_PASSWORD | cut -d'"' -f2)"
echo "Minio root user:"
echo "  username: ${username}"
echo "  password: ${password}"

# Open the console. Use the username/password.
kubectl port-forward svc/myminio-console 9443:9443
# or:
# minikube service --url myminio-console

# Install the minio cli.
brew install minio-mc

# Port forward the minio service port.
kubectl port-forward svc/myminio-hl 9000

# Set the mc client to our minio tenant.
mc alias set myminio https://localhost:9000 "${username}" "${password}" --insecure

# Create a bucket for the pr-review-workflow.
mc mb myminio/pr-review-workflow --insecure

# Create a secret for argo to access minio.
kubectl create secret generic minio-credentials \
    --from-literal=accessKey="${username}" \
    --from-literal=secretKey="${password}"

# We're going to configure argo to point to minio. This requires the namespace
# qualified service name. This little snippet is janky - we're grabbing the kube
# context namespace (as all the other commands in this script don't use '-n' we
# are essentially doing everything in the current context namespace).
# Get that namespace - we need it for the service URL used in the S3 config
# below.
namespace="$(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')"
namespace="${namespace:-default}"

# Create artifact repository configmap for argo workflows.
# This configures Argo to store workflow artifacts in MinIO.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: artifact-repositories
  annotations:
    workflows.argoproj.io/default-artifact-repository: default-artifact-repository
data:
  default-artifact-repository: |
    s3:
      bucket: pr-review-workflow
      endpoint: minio.${namespace}.svc.cluster.local:443
      # MinIO uses TLS, so we set insecure: false and provide the CA certificate.
      # The CA certificate comes from the myminio-tls secret created by the MinIO operator.
      # Use full DNS name (minio.default.svc.cluster.local) to match the certificate.
      insecure: false
      caSecret:
        name: myminio-tls
        key: public.crt
      # Credentials to minio's S3 backend.
      accessKeySecret:
        name: minio-credentials
        key: accessKey
      secretKeySecret:
        name: minio-credentials
        key: secretKey
EOF
```
