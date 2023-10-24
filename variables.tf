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

variable "gdd_access_key" {
  description = "The access key for GoDaddy"
  type        = string
  sensitive   = true
  # default     = "gdd_access_key"
}

variable "gdd_secret_key" {
  description = "The secret key for GoDaddy"
  type        = string
  sensitive   = true
  # default     = "gdd_secret_key"
}

variable "domain" {
  description = "List of subdomains to set the IP for"
  type        = string
  default     = "mydomain.com"
}

variable "subdomain_list" {
  description = "List of subdomains to set the IP for"
  type        = list(string)
  default     = ["argo","us","margo"]
}

variable "annotations" {
  description = "Annotations for the Ingress resource"
  type        = string
  default     = <<-EOT
  kubernetes.io/ingress.class: "traefik"
  cert-manager.io/cluster-issuer: "letsencrypt-prod"
  ingress.kubernetes.io/force-ssl-redirect: "true"
  ingress.kubernetes.io/ssl-redirect: "true"
  traefik.ingress.kubernetes.io/router.tls: "true"
  traefik.ingress.kubernetes.io/affinity: "true"
  traefik.ingress.kubernetes.io/frontend-entry-points: http,https
  traefik.ingress.kubernetes.io/redirect-entry-point: https
  EOT
}

variable "hosts_to_services" {
  description = "List of maps containing host, service, port, path, and namespace details for Ingress rules"
  type = list(object({
    host      = string
    service   = string
    port      = number
    path      = string
    namespace = string
    path_type = string
  }))
  default = [
    # {
    #   host      = "argo.mydomain.com"
    #   service   = "argocd-server"
    #   port      = 88
    #   path      = "/"
    #   namespace = "argocd"
    #   path_type = "Prefix"
    # },
    # {
    #   host      = "us.mydomain.com"
    #   service   = "web-helm"
    #   port      = 8000
    #   path      = "/"
    #   namespace = "web-net"
    #   path_type = "Prefix"
    # }
  ]
}
