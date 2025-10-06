
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
      url           = "git@github.com:${var.infra_repo_owner}/${var.github_infra_repo_path}.git"
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
        "repoURL"        = "git@github.com:${var.infra_repo_owner}/${var.github_infra_repo_path}.git"
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

  cluster_id = "${var.company}-${var.env}-${var.cluster}-${var.location}"
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

    labels = merge({
      "company"                        = var.company
      "cluster"                        = var.cluster
      "location"                       = var.location
      "argocd.argoproj.io/secret-type" = "cluster"
    }, var.gitops_addons_labels)

    annotations = merge({
      infra_repo_url                = "git@github.com:${var.infra_repo_owner}/${var.github_infra_repo_path}.git"
      infra_repo_revision           = var.infra_repo_revision
      basedomain                    = var.basedomain
      env_repo_url                  = "git@github.com:${var.env_repo_owner}/${var.github_env_repo_path}.git"
      env_repo_revision             = var.env_repo_revision
      env_repo_addon_overrides_path = var.env_repo_addon_overrides_path != null ? var.env_repo_addon_overrides_path : "overrides/${local.cluster_id}"
    }, var.gitops_addons_annotations)
  }

  data = {
    config   = "{\"tlsClientConfig\":{\"insecure\":false}}"
    name     = "in-cluster"
    server   = "https://kubernetes.default.svc"
    env_name = local.cluster_id
  }

  type = "Opaque"
}

resource "kubectl_manifest" "infrastructure_resource" {
  yaml_body = yamlencode(local.infrastructure_resource)
}
