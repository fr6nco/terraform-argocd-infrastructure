
locals {
  infrastructure_source = {
    "metadata" : {
      "name" : "argocd-infrastructure-base"
      "namespace" : "argocd"
      "annotations" : {
        "managed-by" : "argocd.argoproj.io"
      }
      "labels" : {
        "argocd.argoproj.io/secret-type" : "repository"
      }
    },
    data : {
      name          = "argocd-infrastructure-base"
      sshPrivateKey = tls_private_key.infra_base_deploy_key.private_key_pem
      type          = "git"
      url           = coalesce(var.infra_repo_url_override, "git@github.com:fr6nco/${var.github_infra_repo_path}.git")
    }
  }

  infrastructure_resource = {
    "apiVersion" = "argoproj.io/v1alpha1"
    "kind"       = "Application"
    "metadata" = {
      "name"      = "infra"
      "namespace" = "argocd"
      "finalizers" = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    "spec" = {
      "project" = "default"
      "source" = {
        "repoURL"        = coalesce(var.infra_repo_url_override, "git@github.com:fr6nco/${var.github_infra_repo_path}.git")
        "targetRevision" = var.infra_repo_revision
        "path"           = "apps"
      }
      "destination" = {
        "namespace" = "argocd"
        "server"    = "https://kubernetes.default.svc"
      }
      "syncPolicy" = {
        "automated" = {
          "prune"    = true
          "selfHeal" = true
        }
      }
    }
  }
}

resource "tls_private_key" "infra_base_deploy_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Add the ssh key as a deploy key
resource "github_repository_deploy_key" "infra_base_deploy_key" {
  title      = "Deploy key for infra base"
  repository = var.github_infra_repo_path
  key        = tls_private_key.infra_base_deploy_key.public_key_openssh
  read_only  = true
}

resource "kubernetes_secret" "infrastructure_source" {
  metadata {
    name        = local.infrastructure_source.metadata.name
    namespace   = local.infrastructure_source.metadata.namespace
    annotations = local.infrastructure_source.metadata.annotations
    labels      = local.infrastructure_source.metadata.labels
  }

  data = local.infrastructure_source.data
}

resource "kubernetes_secret" "incluster-config" {
  metadata {
    name      = "cluster-kubernetes.default.svc"
    namespace = "argocd"

    labels = {
      "company"                        = var.company
      "cluster"                        = var.cluster
      "location"                       = var.location
      "argocd.argoproj.io/secret-type" = "cluster"
      "argo_cd_enabled"                = "true"
    }

    annotations = {
      infra_repo_url      = coalesce(var.infra_repo_url_override, "git@github.com:fr6nco/${var.github_infra_repo_path}.git")
      infra_repo_revision = var.infra_repo_revision
      basedomain          = var.basedomain
    }
  }

  data = {
    config   = "{\"tlsClientConfig\":{\"insecure\":false}}"
    name     = "in-cluster"
    server   = "https://kubernetes.default.svc"
    env_name = "${var.company}-${var.cluster}-${var.location}"
  }

  type = "Opaque"
}

resource "kubectl_manifest" "infrastructure_resource" {
  yaml_body = yamlencode(local.infrastructure_resource)
}
