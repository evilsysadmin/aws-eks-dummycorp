# resource "helm_release" "ebs_csi_driver" {
#   name       = "ebs-csi-driver"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
#   version    = "2.20.0"  # Asegúrate de usar la versión más reciente compatible

#   values = [
#     <<-EOF
#     controller:
#       replicaCount: 2
#       serviceAccount:
#         create: true
#         name: ebs-csi-controller-sa
#         annotations:
#           eks.amazonaws.com/role-arn: ${aws_iam_role.ebs_csi_controller_role.arn}
#     EOF
#   ]
# }

# # resource "helm_release" "grafana" {
# #   name       = "grafana"
# #   repository = "https://grafana.github.io/helm-charts"
# #   chart      = "grafana"
# #   namespace  = "monitoring"

# #   values = [
# #     <<-EOT
# #     service:
# #       type: LoadBalancer
# #       annotations:
# #         external-dns.alpha.kubernetes.io/hostname: grafana.dummycorp.evilsysadmin.click
# #         external-dns.alpha.kubernetes.io/ttl: "60"
# #     datasources:
# #       datasources.yaml:
# #         apiVersion: 1
# #         datasources:
# #         - name: Prometheus
# #           type: prometheus
# #           url: http://prometheus-server.monitoring.svc.cluster.local
# #           access: proxy
# #           isDefault: true
# #     EOT
# #   ]
# # }


# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://charts.bitnami.com/bitnami" # Cambio al repositorio de Bitnami que es más estable
#   chart      = "external-dns"
#   namespace  = "kube-system"
#   version    = "6.13.1" # Especifica una versión conocida

#   set {
#     name  = "provider"
#     value = "aws"
#   }

#   set {
#     name  = "aws.region"
#     value = local.region
#   }

#   set {
#     name  = "policy"
#     value = "sync"
#   }

#   set {
#     name  = "registry"
#     value = "txt"
#   }

#   set {
#     name  = "txtOwnerId"
#     value = module.eks.cluster_name
#   }

#   set {
#     name  = "domainFilters[0]"
#     value = "evilsysadmin.click"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.external_dns_irsa_role.arn
#   }

#   depends_on = [module.eks]
# }

# ## ALB INGRESS CONTROLLER

# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"  

#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_name  # Cambia esto por el nombre de tu clúster EKS
#   }

#   set {
#     name  = "autoDiscoverAwsVpcID"
#     value = "true"
#   }

#   set {
#     name  = "awsRegion"
#     value = "eu-west-1"  # Cambia a la región de tu clúster
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.alb_ingress_controller.arn
#   }

#   set {
#     name  = "rbac.create"
#     value = "true"
#   }
# }
