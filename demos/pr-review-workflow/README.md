# pr-review-workflow

This workflow reviews all requests in a GitHub repository.

## Installation

```bash
# Ensure Argo / Ark Workflows is installed.
pushd ~/repos/github/McK-Internal/agents-at-scale-marketplace/ark-workflows
devspace deploy
popd

# Create a PVC to use as a shared workspace.
kubectl apply -f ./workspace-pvc.yaml

# Install the shell MCP server, used to run git commands and other shell tools.
pushd ../../mcp-servers/shell
devspace deploy
popd

# Patch the deployment to mount the workspace PVC
kubectl patch deployment shell --type='json' -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes",
    "value": [{"name": "workspace", "persistentVolumeClaim": {"claimName": "github-mcp-workspace"}}]
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts",
    "value": [{"name": "workspace", "mountPath": "/workspace"}]
  }
]'
kubectl rollout restart deployment shell

# Install the GitHub MCP server with the same workspace PVC.
# TODO: Add GitHub MCP installation instructions

# Create the workflow template.
kubectl apply -f ./analyze-pull-requests.yaml

# Open the Argo UI. If you are using `devspace dev` for `ark-workflows` this
# port is automatically forwarded.
kubectl port-forward 2746:2746 &
open http://localhost:2746

# Run the workflow. Suggested values:
# - 
```
