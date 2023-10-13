variable "GOOGLE_PROJECT" {
  type        = string
  default     = "devopsgo-385622"
  description = "GCP project name"
}

variable "GOOGLE_REGION" {
  type        = string
  default     = "europe-west1-c"
  description = "region name"
}

variable "GKE_MACHINE_TYPE" {
  type        = string
  default     = "n1-standard-1"
  description = "Machine type"
}

variable "GKE_NUM_NODES" {
  type        = number
  default     = 1
  description = "GKE nodes number"
}

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
  default     = "kbot-control"
  description = "Repo sync with flux"
}

variable "ARGO_GITHUB_REPO" {
  type        = string
  default     = "webthecars"
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

