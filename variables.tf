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

variable "infra_repo_url_override" {
  description = "Override the default URL of the infrastructure repository"
  type        = string
  default     = ""
}

variable "company" {
  description = "Name of the company"
  type        = string
  default     = "tbotech"
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
