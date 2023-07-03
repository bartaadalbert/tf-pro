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
  default     = "kbot-control-gke"
  description = "Repo sync with flux"
}

variable "KIND_CLUSTER_NAME" {
  type        = string
  default     = "kbot-cluster"
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
  default     = 1
}

variable "TG_BOT_TOKEN" {
  type        = string
  description = "TG bot token"
  sensitive   = true  # This will prevent the token from being shown in the CLI output
}

variable "namespace" {
  type        = string
  description = "namspace for app"
  default     = "default"
}

variable "secret_name" {
  description = "The name of the secret"
  type        = string
  default     = "kbot"
}


variable "kms_key_ring" {
  description = "The name of the KMS key ring"
  type        = string
  default     = "sops-flux-1"
}

variable "kms_crypto_key" {
  description = "The name of the KMS crypto key"
  type        = string
  default     = "sops-key-flux-1"
}

variable "secrets" {
  description = "Map of secret names and key-value pairs"
  type        = map(map(string))
  default     = {}
}

variable "sops_version" {
  description = "The version of SOPS to download"
  type        = string
  default     = "v3.7.3"
}

variable "sops_os" {
  description = "The target operating system for SOPS"
  type        = string
  default     = "linux"
}

variable "sops_arch" {
  description = "The target architecture for SOPS"
  type        = string
  default     = "amd64"
}

