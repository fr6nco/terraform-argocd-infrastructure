variable "github_infra_repo_path" {
  description = "Path of the infrastructure repository"
  type        = string
  default     = "argocd-infrastructure-base"
}

variable "infra_repo_revision" {
  description = "Revision of the infrastructure repository"
  type        = string
  default     = "HEAD"
}

variable "infra_repo_owner" {
  description = "Owner of the infrastructure repository"
  type        = string
  default     = "fr6nco"
}

variable "github_env_repo_path" {
  description = "Path of the environment repository"
  type        = string
  nullable    = true
  default     = "argocd-infrastructure-base"
}

variable "env_repo_revision" {
  description = "Revision of the environment repository"
  type        = string
  default     = "HEAD"
}

variable "env_repo_owner" {
  description = "Owner of the environment repository"
  type        = string
  default     = "fr6nco"
}

variable "env_repo_addon_overrides_path" {
  description = "Path to the addon overrides in the environment repository"
  type        = string
  nullable    = true
  default     = null
}

# Deprecated, use infra_repo_owner and github_infra_repo_path instead
variable "infra_repo_url_override" {
  description = "Override the default URL of the infrastructure repository"
  type        = string
  default     = ""
  deprecated  = "Use infra_repo_owner and github_infra_repo_path instead"
}

variable "company" {
  description = "Name of the company"
  type        = string
  default     = "tbotech"
}

variable "env" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "cluster" {
  description = "Name of the cluster"
  type        = string
  default     = "spaceup"
}

variable "location" {
  description = "Location of the cluster"
  type        = string
  default     = "atelier"
}

variable "basedomain" {
  description = "Domain name where to expose services"
  type        = string
  default     = "spaceup.tbotech.sk"
}

variable "gitops_addons_labels" {
  description = "Labels to apply to GitOps addons"
  type        = map(string)
  default     = {}
}

variable "gitops_addons_annotations" {
  description = "Annotations to apply to GitOps addons"
  type        = map(string)
  default     = {}
}

variable "additional_repositories" {
  description = "Additional repositories to add to ArgoCD"
  type        = map(any)
  default     = {}
}
