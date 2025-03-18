resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "kubernetes_storage_class" "ebs" {
  metadata {
    name = "ebs-storage-class"
  }

  storage_provisioner = "kubernetes.io/aws-ebs"  # Provisionador para EBS

  parameters = {
    type   = "gp3"  # O "gp3", dependiendo de tus necesidades
    fsType = "ext4"
  }

  reclaim_policy     = "Retain"
  volume_binding_mode = "Immediate"
}

# resource "kubernetes_persistent_volume_claim" "prometheus_alertmanager_pvc" {
#   metadata {
#     name      = "storage-prometheus-alertmanager-0"
#     namespace = "monitoring"
#   }

#   spec {
#     access_modes = ["ReadWriteOnce"]

#     resources {
#       requests = {
#         storage = "2Gi"
#       }
#     }

#     storage_class_name = kubernetes_storage_class.ebs.metadata[0].name  # Usamos el StorageClass creado
#   }
# }

# ConfigMap para almacenar los ARNs de los roles
resource "kubernetes_config_map" "aws_iam_roles" {
  metadata {
    name      = "aws-iam-roles"
    namespace = "argocd" # Asegúrate de que el namespace argocd ya exista
  }

  data = {
    "external-dns-role-arn" = aws_iam_role.external_dns_irsa_role.arn
    "ebs-csi-role-arn"      = aws_iam_role.ebs_csi_controller_role.arn
    "alb-ingress-controller" = aws_iam_role.alb_ingress_controller.arn
    "cert-manager-role-arn" = aws_iam_role.cert_manager_role.arn
    "prometheus-role-arn" = aws_iam_role.prometeus_role.arn
      
    # Añade aquí otros roles si los necesitas para Prometheus, Grafana, etc.
  }

  depends_on = [
    aws_iam_role.external_dns_irsa_role,
    aws_iam_role.ebs_csi_controller_role
    # Añade aquí otros roles si los necesitas
  ]
}

# # Crear el ConfigMap con el Zone ID
# resource "kubernetes_config_map" "route53_config" {
#   metadata {
#     name      = "route53-config"
#     namespace = "core-infra-apps"
#   }
#   data = {
#     "zone_id" = aws_route53_zone.main.zone_id
#   }
# }
