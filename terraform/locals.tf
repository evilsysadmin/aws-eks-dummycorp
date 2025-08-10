locals {
  eks_version       = "1.32"
  cluster_name      = "eks-dummycorp-cluster"
  eks_instance_type = "t3.medium"
  region            = "eu-west-1"
  vpc_cidr          = "10.0.0.0/16"
  grafana_hostname  = "grafana.dummycorp.evilsysadmin.click"
  azs               = slice(data.aws_availability_zones.available.names, 0, 3)
}
