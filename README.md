# DummyCorp EKS Infrastructure

This repo sets up a complete EKS cluster with monitoring and GitOps for a fictional company called DummyCorp. It's basically everything you need to run a proper Kubernetes setup on AWS, minus the drama of convincing your team to adopt GitOps.

## What you get

Pretty much a production-ready EKS cluster with all the bells and whistles:

- EKS cluster running on AWS (obviously)
- Prometheus and Grafana for metrics and dashboards
- ArgoCD for GitOps deployments
- External DNS that automatically creates Route53 records
- Proper networking with VPC, subnets, and security groups
- IAM roles configured correctly (IRSA and all that)

The cluster is set up in eu-west-1 and uses the domain `evilsysadmin.click` for external access. Services will be available at environment-specific subdomains once everything is deployed.

## Prerequisites

You'll need a few things installed:
- Terraform (recent version)
- AWS CLI configured with credentials
- kubectl for cluster access

Make sure your AWS user has enough permissions to create EKS clusters, VPCs, IAM roles, and Route53 records. If you get permission errors, that's probably why.

## Project structure

```
terraform/           # All the Terraform code
environments/dev/    # Environment-specific configs
apps/               # Kubernetes manifests and ArgoCD apps
scripts/            # Helper scripts
```

The Terraform code uses the official AWS EKS module instead of reinventing the wheel. Most of the heavy lifting is done by proven modules.

## Deployment

Dead simple with the Makefile:

```bash
# Plan the deployment (always do this first)
make tf-plan

# Deploy everything
make tf-apply

# Get kubectl access
make kubectl-config
```

By default everything deploys to the `dev` environment. If you want to deploy to a different environment (like prod), just set the ENV variable:

```bash
make tf-apply ENV=prod
```

The deployment takes about 15-20 minutes because AWS is slow at creating EKS clusters. Grab a coffee.

## What gets deployed

The Terraform creates about 86 resources, which sounds like a lot but most of it is standard AWS networking stuff:

- A VPC with public and private subnets across 3 AZs
- EKS cluster with managed node group (3 t3.medium instances by default)
- All the necessary IAM roles and security groups
- Prometheus for metrics collection
- Grafana for dashboards with Prometheus as data source
- ArgoCD for GitOps workflows
- External DNS that manages Route53 records automatically

Everything is properly tagged and follows AWS best practices. The setup uses a single NAT gateway to keep costs reasonable for development.

## DNS and External Access

The infrastructure uses environment-aware DNS subdomains for all services. External DNS automatically creates Route53 records based on the environment:

### Environment URLs

**Development environment (default):**
- Grafana: `dev.grafana.dummycorp.evilsysadmin.click`
- Prometheus: `dev.prometheus.dummycorp.evilsysadmin.click`
- ArgoCD: `dev.argocd.dummycorp.evilsysadmin.click`

**Production environment:**
```bash
make tf-apply ENV=prod
```
- Grafana: `prod.grafana.dummycorp.evilsysadmin.click`
- Prometheus: `prod.prometheus.dummycorp.evilsysadmin.click`
- ArgoCD: `prod.argocd.dummycorp.evilsysadmin.click`

### How it works

External DNS reads service annotations and automatically creates Route53 records:

```yaml
annotations:
  external-dns.alpha.kubernetes.io/hostname: dev-grafana.dummycorp.evilsysadmin.click
  external-dns.alpha.kubernetes.io/ttl: "60"
```

The hostnames are dynamically generated based on the environment variable, so you can run multiple environments simultaneously without DNS conflicts.

### Custom environments

To create a custom environment like staging:

```bash
# Create staging config
mkdir -p environments/staging
cp environments/dev/terraform.tfvars environments/staging/
# Edit staging values...

# Deploy staging
make tf-apply ENV=staging
```

This will create `staging-grafana.dummycorp.evilsysadmin.click` automatically.

### Access and credentials

After deployment, you can access the services using the URLs above. Default credentials:

- **Grafana**: admin/admin (you'll be prompted to change on first login)
- **ArgoCD**: Check the admin secret in the argocd namespace
- **Prometheus**: No authentication required

Use `kubectl get services -A` to find LoadBalancer IPs if external DNS hasn't propagated yet.

## Environments

The code supports multiple environments through the `ENV` variable. Currently there's just a dev environment configured, but you can easily add more by creating new directories under `environments/`.

Each environment should have its own `terraform.tfvars` file with environment-specific settings like cluster name, instance types, and scaling parameters.

Example for production:

```bash
mkdir -p environments/prod
cp environments/dev/terraform.tfvars environments/prod/
# Edit prod-specific values like:
# cluster_name = "dummycorp-prod"
# instance_type = "t3.large"
# min_nodes = 3
```

## Costs

This setup isn't cheap. You're looking at roughly:
- EKS control plane: $73/month
- 3x t3.medium nodes: ~$150/month
- NAT gateway: ~$45/month
- Load balancers: ~$20/month each
- Route53: $1/month

Total is around $300/month. You can reduce costs by using smaller instances or fewer nodes, but remember this affects performance.

For cost optimization, edit `environments/dev/terraform.tfvars`:

```hcl
instance_type = "t3.small"  # Saves ~$30/month
min_nodes = 1               # Saves ~$100/month
max_nodes = 3
```

## Cleanup

When you're done experimenting:

```bash
make tf-destroy
```

This will delete everything. Make sure you really want to do this because there's no undo button.

## Troubleshooting

If the deployment fails, it's usually one of these issues:

- **Permission errors**: Your AWS user needs more IAM permissions
- **Resource limits**: Check your AWS service quotas
- **Region issues**: Some resources might not be available in your region
- **Terraform state**: Delete `.terraform` directories and re-run `terraform init`
- **DNS propagation**: External DNS records can take a few minutes to propagate

The most common issue is IAM permissions. The AWS user needs to be able to create EKS clusters, which requires quite a few permissions.

### Common fixes

```bash
# Reset Terraform state
rm -rf terraform/.terraform*
cd terraform && terraform init

# Check AWS permissions
aws sts get-caller-identity
aws eks describe-cluster --name test-cluster --region eu-west-1

# Verify DNS records
dig dev-grafana.dummycorp.evilsysadmin.click
```

## What's next

This is a solid foundation for a Kubernetes platform. Some things you might want to add:

- A demo application to actually run something on the cluster
- Loki for log aggregation (currently only metrics)
- Certificate management with cert-manager
- More sophisticated monitoring and alerting
- CI/CD pipelines that deploy through ArgoCD
- Chaos engineering tools for resilience testing

The cluster is ready for GitOps workflows, so you can point ArgoCD at your application repositories and let it handle deployments.

## Notes

The domain `evilsysadmin.click` is real and configured in Route53. External DNS will automatically create subdomains as needed.

The cluster uses IRSA (IAM Roles for Service Accounts) for security, which is the proper way to give pods AWS permissions without storing credentials.

All persistent volumes are disabled by default to keep things simple and reduce costs. In production you'd want proper storage for Prometheus and Grafana.

---

This project demonstrates infrastructure as code, Kubernetes, observability, and GitOps patterns. 

It's meant to be a practical example of how to set up a modern platform on AWS.
