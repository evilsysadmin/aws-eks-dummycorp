resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"

  values = [
    <<-EOT
    service:
      type: LoadBalancer
      annotations:
        external-dns.alpha.kubernetes.io/hostname: ${local.grafana_hostname}
        external-dns.alpha.kubernetes.io/ttl: "60"
    datasources:
      datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server.monitoring.svc.cluster.local
          access: proxy
          isDefault: true
    EOT
  ]
}


resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://charts.bitnami.com/bitnami" # Cambio al repositorio de Bitnami que es más estable
  chart      = "external-dns"
  namespace  = "kube-system"
  version    = "6.13.1" # Especifica una versión conocida

  set = [
    {
      name  = "provider"
      value = "aws"
    },

    {
      name  = "aws.region"
      value = local.region
    },

    {
      name  = "policy"
      value = "sync"
    },

    {
      name  = "registry"
      value = "txt"
    },

    {
      name  = "txtOwnerId"
      value = module.eks.cluster_name
    },

    {
      name  = "domainFilters[0]"
      value = "evilsysadmin.click"
    },

    {
      name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.external_dns_irsa_role.arn
    }
  ]

  depends_on = [module.eks]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
}
