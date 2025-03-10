locals {
  eks_version       = "1.32"
  cluster_name      = "dummycorp"
  eks_instance_type = "t3a.large"
  eks_nodes_min_size = 4
  eks_nodes_max_size = 4
  eks_nodes_desired_size = 4
  region            = "eu-west-1"
  vpc_cidr          = "10.0.0.0/16"
  grafana_hostname  = "grafana.dummycorp.evilsysadmin.click"
  azs               = slice(data.aws_availability_zones.available.names, 0, 3)

  public_subnets = module.vpc.public_subnets
  subnets_string = join(",", local.public_subnets)
  
}
