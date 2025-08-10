module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_name                             = local.cluster_name
  cluster_version                          = local.eks_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  authentication_mode = "API"
  # EKS Addons
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [local.eks_instance_type]

      min_size = 3
      max_size = 3
      # This value is ignored after the initial creation
      # https://github.com/bryantbiggs/eks-desired-size-hack
      desired_size         = 3
      create_iam_node_role = true
      node_iam_role_arn    = aws_iam_role.eks_node_role.arn

      vpc_security_group_ids = [aws_security_group.eks_nodes.id] # 🔥 Asigna el SG aquí
    }
  }

  tags = {
    Name = "dummycorp-node"
  }
}
