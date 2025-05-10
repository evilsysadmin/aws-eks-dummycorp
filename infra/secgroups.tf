resource "aws_security_group" "eks_additional_sg" {
  name        = "eks-node-additional-sg"
  description = "Additional security group for EKS nodes to allow traffic for ALB"
  vpc_id      = module.vpc.vpc_id

  # Permitir todo el tráfico desde el ALB a los nodos
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
    description = "Allow traffic from ALB to nodes"
  }

  # Regla para permitir tráfico desde pods a nodos
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
    description = "Allow pod-to-node communication"
  }

  # Permitir tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "eks-node-additional-sg"
  }
}


resource "aws_security_group" "eks_nodes" {
  vpc_id = module.vpc.vpc_id
  name   = "eks-nodes-sg"

  ingress {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true # Permite que los nodos hablen entre ellos
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [module.eks.cluster_security_group_id] # Permite tráfico del control plane
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-nodes-sg"
  }
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block] # Permite tráfico HTTPS desde toda la VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-endpoints-sg"
  }
}
