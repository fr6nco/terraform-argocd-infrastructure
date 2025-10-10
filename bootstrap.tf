
resource "kubernetes_secret" "repo" {
  for_each = var.additional_repositories

  metadata {
    name      = each.key
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = each.value
}


resource "kubectl_manifest" "additional_bootstrap_app" {
  for_each = var.additional_bootstrap_apps

  yaml_body = yamlencode({
    "apiVersion" : "argoproj.io/v1alpha1",
    "kind" : "Application",
    "metadata" : {
      "name" : each.key,
      "namespace" : "argocd",
      "finalizers" : [
        "resources-finalizer.argocd.argoproj.io"
      ]
    },
    "spec" : each.value
  })
}
