# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://kubernetes-sigs.github.io/external-dns/"
#   chart      = "external-dns"
#   namespace  = "kube-system"

#   set {
#     name  = "provider"
#     value = "aws"
#   }

#   set {
#     name  = "policy"
#     value = "sync" # Puede ser upsert-only, pero sync es más agresivo
#   }

#   set {
#     name  = "registry"
#     value = "txt"
#   }

#   set {
#     name  = "txtOwnerId"
#     value = module.eks.cluster_id
#   }

#   set {
#     name  = "domainFilters[0]"
#     value = "evilsysadmin.click"
#   }
# }
