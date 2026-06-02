# terraform — ark-demo environment

Provisions the cheapest credible Kubernetes demo on AWS and installs Ark + the
`ark-demo` chart onto it.

## What it builds

- **network** — VPC, single public subnet, IGW, security group, Elastic IP.
  No NAT gateway, no load balancer (cost).
- **compute** — one Graviton EC2 (`t4g.medium`, on-demand by default) running
  [k3s](https://k3s.io) (full Kubernetes, single binary). cloud-init installs
  k3s and writes a kubeconfig (server rewritten to the Elastic IP) into SSM
  Parameter Store.
- **ark** — reads that kubeconfig and installs, via `helm_release`:
  - cert-manager (cluster) and the Ark operator (`ark-controller`,
    `ark-completions`) in `ark-system`;
  - a tenant namespace (`demo`) provisioned by `ark-tenant` (service account,
    RBAC, quota), into which the local `ark-demo` chart deploys its
    Models/Agents/Teams.

Cost: ~$27/mo on-demand, ~$10/mo spot. Real saving is `destroy` between demos.

## Layout

```
terraform/
├── bootstrap/          # run ONCE, manually — creates the GitHub OIDC role CI assumes
├── environments/demo/  # the only thing the pipeline touches
└── modules/{network,compute,ark}
```

## First run (the k3s bootstrap caveat)

The `helm`/`kubernetes` providers read the kubeconfig from SSM, which only
exists after the EC2 instance has booted. On a clean state the cluster must
exist before those providers can configure, so apply in two steps the first
time:

```bash
cd environments/demo
terraform init
terraform apply -target=module.network -target=module.compute   # bring up k3s
terraform apply                                                  # install Ark + chart
```

Subsequent applies (and the CI pipeline, once state exists) are a single
`terraform apply`.

## State

Uses HCP Terraform (app.terraform.io, free tier) — see `environments/demo/backend.tf`.
An S3 + native-lockfile alternative is commented in the same file.

## Optional marketplace extras

The `make install` flow also runs `ark install marketplace/...` (the `ark` CLI).
Those are not provisioned here — run them manually against the cluster after
apply if wanted.
