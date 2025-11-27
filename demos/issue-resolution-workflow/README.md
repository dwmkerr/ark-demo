# issue-resolution-workflow

This workflow reviews open issues in a GitHub repository and uses an agent to suggest a resolution plan for each.

For detailed explanation of the workflow structure and Ark/Argo concepts, see the [PR Review Workflow](../pr-review-workflow/README.md).

## Installation

Ensure [Ark](http://github.com/mckinsey/agents-at-scale-ark) and Argo Workflows are installed:

```bash
npm install -g @agents-at-scale/ark
ark install
ark status --wait-for-ready=5m
```

Install Argo Workflows with Minio for artifact storage:

```bash
helm upgrade minio-operator operator \
  --install \
  --repo https://operator.min.io \
  --namespace minio-operator \
  --create-namespace \
  --version 7.1.1

helm upgrade argo-workflows \
  oci://ghcr.io/mckinsey/agents-at-scale-ark/charts/argo-workflows \
  --install \
  --set minio.enabled=true
```

Install the GitHub MCP server and workflow:

```bash
helm upgrade --install github-mcp oci://ghcr.io/dwmkerr/charts/github-mcp \
  --set github.token=${GITHUB_TOKEN}

kubectl apply -f https://raw.githubusercontent.com/dwmkerr/ark-demo/refs/heads/main/demos/issue-resolution-workflow/issue-resolution-workflow.yaml
```

## Running the Workflow

Via the Argo Dashboard (http://localhost:2746) or CLI:

```bash
argo submit --from workflowtemplate/issue-resolution-workflow \
    -p github-repo=mckinsey/agents-at-scale-ark \
    --watch
```

Resume when prompted for approval:

```bash
argo resume <workflow_name>
```

Open the dashboards to monitor progress and inspect outputs:

```bash
kubectl port-forward svc/argo-workflows-server 2746:2746 &  # http://localhost:2746
kubectl port-forward svc/myminio-console 9443:9443 &        # https://localhost:9443 (minio/minio123)
kubectl port-forward svc/ark-dashboard 8080:8080 &          # http://localhost:8080
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `github-repo` | `mckinsey/agents-at-scale-ark` | Repository in org/repo format |
| `issue-resolution-agent` | `issue-resolution-agent` | Agent name for issue analysis |
| `updated-since` | `2000-01-01T00:00:00Z` | Only review issues updated since this timestamp |
| `issue-ids` | (empty) | Comma-separated issue IDs to review (if empty, uses all open issues) |
| `gh-token` | (empty) | GitHub token for API access |
