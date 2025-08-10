resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = "monitoring"

  set = [
    {
      name  = "server.service.annotations.external-dns\\.alpha\\.kubernetes\\.io/hostname"
      value = local.prometheus_hostname
    },
    {
      name  = "server.service.type"
      value = "LoadBalancer"
    },

    {
      name  = "server.persistentVolume.enabled"
      value = "false"
    },

    {
      name  = "alertmanager.persistentVolume.enabled"
      value = "false"
    },

    {
      name  = "server.serviceMonitor.namespaceSelector.matchNames"
      value = "monitoring"
    },

    {
      name  = "server.serviceMonitor.selector.matchLabels.release"
      value = "prometheus"
    }
  ]
}

