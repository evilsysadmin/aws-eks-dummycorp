locals {
  eks_version       = "1.32"
  cluster_name      = "dummycorp-cluster"
  eks_instance_type = "t3a.medium"
  eks_nodes_min_size = 4
  eks_nodes_max_size = 4
  eks_nodes_desired_size = 4
  region            = "eu-west-1"
  vpc_cidr          = "10.0.0.0/16"
  grafana_hostname  = "grafana.dummycorp.evilsysadmin.click"
  azs               = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets = module.vpc.public_subnets
  subnets_string = join(",", local.public_subnets)
  repositories = [
    "dummycorp-store-frontend",
    "dummycorp-store-backend"
  ]

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 10 untagged images",
        selection = {
          tagStatus   = "untagged",
          countType   = "imageCountMoreThan",
          countNumber = 10
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Keep only 5 images with release- prefix",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["release-"],
          countType     = "imageCountMoreThan",
          countNumber   = 5
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
  
  common_tags = {
    Environment = "production"
    Application = "dummycorp-store"
  }
}
