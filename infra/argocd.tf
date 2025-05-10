resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "7.8.11"  
  create_namespace = true

  # Usar el archivo values.yaml en lugar de múltiples bloques set
  values = [
    file("${path.module}/argocd-values.yaml")
  ]
  depends_on = [module.eks]
}

resource "helm_release" "argocd_apps" {
  name       = "argocd-apps"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  version    = "1.6.2"  # Última conocida a octubre 2024, verifica la más reciente
  values = [
    file("${path.module}/argocd-apps-values.yaml")
  ]
  depends_on = [helm_release.argocd]  # Asegura que ArgoCD esté instalado primero
}

# Namespace para dummycorp-store
resource "kubernetes_namespace" "dummycorp_store" {
  metadata {
    name = "dummycorp-store"
  }
}

resource "kubernetes_namespace" "core_infra_apps" {
  metadata {
    name = "core-infra-apps"
  }
}
