variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "eks_cluster_name" {
  description = "EKS Cluster Name"
  default     = "dummycorp-cluster"
}

variable "subnet_cidr_blocks" {
  description = "List of CIDR blocks for subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "eks_instance_types" {
  description = "EC2 instance type for EKS nodes"
  type        = list(string)
}

variable "eks_capacity_type" {
  type    = string
  default = "SPOT"
}

variable "min_nodes" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "environment" {
  type    = string
  default = "dev"
}
