output "vpc_id" {
  value = module.vpc.vpc_id
}

output "cluster_name" {
  value = var.eks_cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

