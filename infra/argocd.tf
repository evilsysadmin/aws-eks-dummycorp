resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true

  # Usar el archivo values.yaml en lugar de múltiples bloques set
  values = [
    file("${path.module}/argocd-values.yaml")
  ]

}
