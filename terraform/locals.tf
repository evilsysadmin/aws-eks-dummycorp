locals {
  eks_version         = "1.32"
  cluster_name        = "eks-dummycorp-cluster"
  region              = "eu-west-1"
  vpc_cidr            = "10.0.0.0/16"
  base_domain         = "evilsysadmin.click"
  grafana_hostname    = "${var.environment}.grafana.dummycorp.${local.base_domain}"
  prometheus_hostname = "${var.environment}.prometheus.dummycorp.${local.base_domain}"
  argocd_hostname     = "${var.environment}.argocd.dummycorp.${local.base_domain}"
  azs                 = slice(data.aws_availability_zones.available.names, 0, 3)
}
