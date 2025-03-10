# resource "helm_release" "prometheus" {
#   name       = "prometheus"
#   repository = "https://prometheus-community.github.io/helm-charts"
#   chart      = "prometheus"
#   namespace  = "monitoring"

#   set {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "server.persistentVolume.enabled"
#     value = "false"
#   }

#   set {
#     name  = "alertmanager.persistentVolume.enabled"
#     value = "false"
#   }

#   set {
#     name  = "server.serviceMonitor.namespaceSelector.matchNames"
#     value = "monitoring"
#   }

#   set {
#     name  = "server.serviceMonitor.selector.matchLabels.release"
#     value = "prometheus"
#   }

#   set {
#     name  = "server.serviceAccount.annotations.eks.amazonaws.com/role-arn"
#     value = aws_iam_role.eks_node_role.arn
#   }
# }

