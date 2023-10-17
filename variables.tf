variable "GITHUB_OWNER" {
  type        = string
  default     = "bartaadalbert"
  description = "My github account"
}

variable "GITHUB_TOKEN" {
  type        = string
  description = "Github access token"
  sensitive   = true  # This will prevent the token from being shown in the CLI output
}

variable "FLUX_GITHUB_REPO" {
  type        = string
  default     = "flux-gitops"
  description = "Repo sync with flux"
}

variable "ARGO_GITHUB_REPO" {
  type        = string
  default     = "appname"
  description = "Repo sync with argo"
}

variable "KIND_CLUSTER_NAME" {
  type        = string
  default     = "kbot-cluster"
  description = "My local kind cluster name"
}

variable "K3D_CLUSTER_NAME" {
  type        = string
  default     = "devops-cluster"
  description = "My local kind cluster name"
}

variable "NUM_MASTERS" {
  description = "Number of master nodes."
  type        = number
  default     = 1
}

variable "NUM_WORKERS" {
  description = "Number of worker nodes."
  type        = number
  default     = 2
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "appname"
}

variable "project_targetRevision" {
  description = "Target revision for the application"
  type        = string
  default     = "develop"
}

variable "project_path" {
  description = "Path to the application within the repository"
  type        = string
  default     = "helm"
}

variable "destination_namespace" {
  description = "Namespace on the destination cluster"
  type        = string
  default     = "devops-net"
}

variable "rsa_bits" {
  type        = number
  default     = 4096
  description = "the size of the generated RSA key, in bits"
}

variable "secrets" {
  description = "Map of secret names, their types, namespaces, and key-value pairs"
  type = map(object({
    type      = string
    namespace = string
    data      = map(string)
  }))
  default = {
    "ghcrio-pull-secret" = {
      type      = "kubernetes.io/dockerconfigjson",
      namespace = "devops-net",
      data      = {
        ".dockerconfigjson" = <<EOT
{
  "auths": {
    "ghcr.io": {
      "username": "bartaadalbert",
      "password": "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }
  }
}
EOT
    }
  }
}
sensitive   = true
}
