
locals {
  argocd_base_values = {
    "configs" : {
      "cm" : {
        "admin.enabled" : true,
        "exec.enabled" : true,
      },
      "params" : {
        "server.insecure" : true
      }
    },
    "global" : {
      "dualStack" : {
        "ipFamilies" : [
          "IPv4"
        ],
        "ipFamilyPolicy" : {}
      }
    },
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  create_namespace = true
  chart            = "argo-cd"
  version          = "8.3.3"
  values           = [yamlencode(local.argocd_base_values)]
}


