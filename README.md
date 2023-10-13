# Terraform GitOps Infrastructure with Kind,K3D,Flux,ArgoCD and GitHub

This project is a collection of Terraform modules that sets up a GitOps infrastructure on a local Kubernetes cluster using Kind,K3D,Flux,ArgoCD integrated with a GitHub repository. By default, we use the kubeconfig file for connectivity. However, the project can also be configured to use certificates.
Modules

The project comprises the following modules:

    This module sets up a local Kubernetes cluster using K3D, which allows you to run K3s (a lightweight Kubernetes distribution) within Docker. The module by default leverages a kubeconfig file for connectivity, though it also supports utilizing certificates if configured.
    - Kind Cluster: Establishes a local Kubernetes cluster using Kind.
    - K3D Cluster: Constructs a local Kubernetes cluster utilizing K3D.
    - TLS Private Key: Generates a TLS private key for secure communication.
    - GitHub Repository: Initializes a GitHub repository and sets up the deploy key for Flux.
    - Flux Bootstrap: Installs and configures Flux in your cluster, connecting it to the specified GitHub repository.
    - ArgoCD Bootstrap: Sets up ArgoCD and links it with your repository for GitOps deployments.

```hcl
module "k3d_cluster" {
  source            = "github.com/bartaadalbert/tf-3d-cluster"
  K3D_CLUSTER_NAME  = var.K3D_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS
}

TLS Private Key: This module generates a TLS private key.

module "tls_private_key" {
  source    = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}

GitHub Repository: This module sets up a GitHub repository. It uses the develop branch of the specified repository.

module "github_repository" {
  source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "terra_deploy_key"
}

Flux Bootstrap: This module bootstraps Flux (the GitOps Kubernetes operator) in your K3d cluster and connects it to your GitHub repository. By default, it uses the kubeconfig file for connectivity, but it can also be configured to use certificates.

module "flux_bootstrap" {
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.kind_cluster.kubeconfig
}

ArgoCD bootstrap
module "argocd_bootstrap" {
  source                  = "github.com/bartaadalbert/tf-argocd-bootstrap?ref=master"
  github_repository       = "${var.GITHUB_OWNER}/${var.ARGO_GITHUB_REPO}"
  private_key             = module.tls_private_key.private_key_pem
  kubeconfig              = module.k3d_cluster.kubeconfig
  app_name                = var.app_name
  destination_namespace   = var.destination_namespace
  project_path            = var.project_path
  project_targetRevision  = var.project_targetRevision
  admin_password          = "$2a$12$DM0giBMMw05FA9PeyEjJxuUaVpPx0AeVqxNq.B0jVWGSummn4MthW/n6"
  patch_argocd_password   = true
}
```
# Usage

Clone this repository and navigate to its directory:

git clone -b argocd https://github.com/bartaadalbert/tf-pro
cd tf-pro

Initialize Terraform:
terraform init

Apply the Terraform configuration:
terraform apply

# Remember to provide the necessary variables (GITHUB_OWNER, GITHUB_TOKEN, FLUX_GITHUB_REPO) as required.

If you want to use certificates instead of a kubeconfig file for connectivity, uncomment the relevant lines in the kind_cluster and flux_bootstrap modules.
License

This project is licensed under the terms of the MIT license.

This README is a starting point and may be expanded to provide more detailed instructions for setting up the environment or using this project. For instance, you might want to explain how to get the necessary inputs, provide more examples of usage, or include instructions for using the setup once it's created
