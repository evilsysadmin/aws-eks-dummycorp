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

The cluster is set up in eu-west-1 and uses the domain `evilsysadmin.click` for external access. Grafana will be available at `grafana.dummycorp.evilsysadmin.click` once everything is deployed.

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

## Access and URLs

After deployment, you can access:

- **Grafana**: https://grafana.dummycorp.evilsysadmin.click (admin/admin)
- **ArgoCD**: Check the LoadBalancer service in the argocd namespace
- **Prometheus**: Check the LoadBalancer service in the monitoring namespace

Use `kubectl get services -A` to find the actual URLs if external DNS hasn't propagated yet.

## Environments

The code supports multiple environments through the `ENV` variable. Currently there's just a dev environment configured, but you can easily add more by creating new directories under `environments/`.

Each environment should have its own `terraform.tfvars` file with environment-specific settings like cluster name, instance types, and scaling parameters.

## Costs

This setup isn't cheap. You're looking at roughly:
- EKS control plane: $73/month
- 3x t3.medium nodes: ~$150/month
- NAT gateway: ~$45/month
- Load balancers: ~$20/month each
- Route53: $1/month

Total is around $300/month. You can reduce costs by using smaller instances or fewer nodes, but remember this affects performance.

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

The most common issue is IAM permissions. The AWS user needs to be able to create EKS clusters, which requires quite a few permissions.

## What's next

This is a solid foundation for a Kubernetes platform. Some things you might want to add:

- A demo application to actually run something on the cluster
- Loki for log aggregation (currently only metrics)
- Certificate management with cert-manager
- More sophisticated monitoring and alerting
- CI/CD pipelines that deploy through ArgoCD

The cluster is ready for GitOps workflows, so you can point ArgoCD at your application repositories and let it handle deployments.

## Notes

The domain `evilsysadmin.click` is real and configured in Route53. External DNS will automatically create subdomains as needed.

The cluster uses IRSA (IAM Roles for Service Accounts) for security, which is the proper way to give pods AWS permissions without storing credentials.

All persistent volumes are disabled by default to keep things simple and reduce costs. In production you'd want proper storage for Prometheus and Grafana.

---

This project demonstrates infrastructure as code, Kubernetes, observability, and GitOps patterns. 

It's meant to be a practical example of how to set up a modern platform on AWS.
