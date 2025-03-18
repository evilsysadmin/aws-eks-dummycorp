module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34.0"
  
  cluster_name                             = local.cluster_name
  cluster_version                          = local.eks_version
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  
  authentication_mode = "API"
  
  # EKS Addons
  cluster_addons = {
    coredns                = {
      most_recent = true
    }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {
      most_recent = true
      configuration_values = jsonencode({
        env = {
          # Habilitar los security groups por pod para resolver el problema de los target groups
          ENABLE_POD_ENI = "true"
          # Esto ayuda a que los pods se registren correctamente en los target groups cuando usas anotaciones IP
          AWS_VPC_K8S_CNI_EXTERNALSNAT = "true"
        }
      })
    }
  }
  
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  
  # Configuración de nodos EC2 gestionados
  eks_managed_node_groups = {
    general = {
      name = "general-ng"
      
      instance_types = [local.eks_instance_type]
      capacity_type  = "ON_DEMAND"
      
      min_size     = 3
      max_size     = 5
      desired_size = 3
      
      # Enable security groups per pod (necesario para ALB con targets tipo IP)
      vpc_security_group_ids = [
        aws_security_group.eks_additional_sg.id
      ]
      
      labels = {
        role = "general"
      }
      
      update_config = {
        max_unavailable_percentage = 33
      }
      
      tags = {
        Environment = "production"
        Name        = "dummycorp-ec2-nodes"
      }
    }
    
    
  }
  
  # Configuración de IRSA para AWS Load Balancer Controller
  enable_irsa = true
  
  tags = {
    Name = "dummycorp-cluster"
  }
}