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
- EKS cluster with managed node group (spot instances for cost optimization)
- All the necessary IAM roles and security groups
- Prometheus for metrics collection
- Grafana for dashboards with Prometheus as data source
- ArgoCD for GitOps workflows
- External DNS that manages Route53 records automatically

Everything is properly tagged and follows AWS best practices. The setup uses a single NAT gateway to keep costs reasonable for development.

## Instance sizing and spot instances

The cluster uses spot instances by default to keep costs down. Node instances are configured as t3.large and t3.xlarge because the observability stack (Prometheus + Grafana + ArgoCD) needs decent memory to run properly.

**Why larger instances:**
- Prometheus with scraping: 2-3GB RAM
- Grafana with dashboards: 512MB-1GB RAM  
- ArgoCD: 512MB+ RAM
- System overhead: 1.5GB RAM
- t3.medium (4GB total) would result in constant OOMKills

**Spot instance benefits:**
- 60-70% cost savings compared to on-demand
- Automatic resilience testing (occasional node terminations)
- Multiple instance types for better availability

The instance mix of t3.large (8GB) and t3.xlarge (16GB) ensures the observability stack runs smoothly while keeping costs reasonable.

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
  external-dns.alpha.kubernetes.io/hostname: dev.grafana.dummycorp.evilsysadmin.click
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

This will create `staging.grafana.dummycorp.evilsysadmin.click` automatically.

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
# instance_types = ["t3.large", "t3.xlarge"]
# min_nodes = 3
```

## Costs

This setup uses spot instances to keep costs reasonable, but it's still not free:

**With spot instances:**
- EKS control plane: $73/month
- 3x t3.large spot nodes: ~$75/month (vs $150 on-demand)
- NAT gateway: ~$45/month
- Load balancers: ~$20/month each
- Route53: $1/month

Total is around $200/month with spot instances (vs $300+ on-demand).

**Cost optimization tips:**
- Spot instances are already enabled by default
- Single NAT gateway instead of one per AZ
- No persistent volumes for monitoring stack
- LoadBalancer services only where needed

For further cost reduction, edit `environments/dev/terraform.tfvars`:

```hcl
min_nodes = 1               # Start with single node
max_nodes = 3               # Scale up when needed
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
- **Terraform state**: Review terraform state, maybe file its corrupted. Use `terraform state list` to check
- **DNS propagation**: External DNS records can take a few minutes to propagate
- **Spot instance unavailability**: AWS might not have spot capacity in your AZs

The most common issue is IAM permissions. The AWS user needs to be able to create EKS clusters, which requires quite a few permissions.

### Common fixes

```bash

# Check AWS permissions
aws sts get-caller-identity
aws eks describe-cluster --name test-cluster --region eu-west-1

# Verify DNS records
dig dev.grafana.dummycorp.evilsysadmin.click

# Check spot instance availability
aws ec2 describe-spot-price-history --instance-types t3.large --max-results 1
```

### Handling spot instance interruptions

Spot instances can be terminated with 2-minute notice. The infrastructure handles this gracefully:

- Multiple instance types reduce interruption risk
- Kubernetes reschedules pods to available nodes
- Cluster autoscaler adds new nodes when needed
- No data loss (persistent volumes disabled by design)

If you need guaranteed availability, switch to on-demand instances in your terraform.tfvars:

```hcl
# In environments/dev/terraform.tfvars
capacity_type = "ON_DEMAND"
```

## What's next

This is a solid foundation for a Kubernetes platform. Some things that could be added:

- A demo application to run workloads on the cluster
- Loki for log aggregation (currently only metrics)
- Certificate management with cert-manager
- More sophisticated monitoring and alerting
- CI/CD pipelines that deploy through ArgoCD
- Chaos engineering tools for resilience testing
- Pod disruption budgets for better spot instance handling

The cluster is ready for GitOps workflows and can be pointed at application repositories for automated deployments.

## Notes

The domain `evilsysadmin.click` is real and configured in Route53. External DNS will automatically create subdomains as needed.

The cluster uses IRSA (IAM Roles for Service Accounts) for security, which is the proper way to give pods AWS permissions without storing credentials.

All persistent volumes are disabled by default to keep things simple and reduce costs. In production you'd want proper storage for Prometheus and Grafana.

Spot instances provide excellent cost savings and real-world resilience testing. The occasional node termination teaches you proper Kubernetes scheduling and helps validate your application's fault tolerance.

---

This project demonstrates infrastructure as code, Kubernetes, observability, GitOps patterns, and cost optimization strategies. It's meant to be a practical example of how to set up a modern platform on AWS without breaking the bank.
