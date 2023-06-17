# Terraform GitOps Infrastructure with Kind, Flux, and GitHub

This project is a collection of Terraform modules that sets up a GitOps infrastructure on a local Kubernetes cluster using Kind and Flux, integrated with a GitHub repository. By default, we use the kubeconfig file for connectivity. However, the project can also be configured to use certificates.
Modules

The project comprises the following modules:

    Kind Cluster: This module sets up a local Kubernetes cluster using Kind (Kubernetes in Docker). By default, it uses a kubeconfig file for connectivity, but it can also be configured to use certificates.

```hcl
module "kind_cluster" {
  source            = "github.com/bartaadalbert/tf-kind-cluster"
  KIND_CLUSTER_NAME = var.KIND_CLUSTER_NAME
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
  public_key_openssh_title = "flux_deploy_key"
}

Flux Bootstrap: This module bootstraps Flux (the GitOps Kubernetes operator) in your Kind cluster and connects it to your GitHub repository. By default, it uses the kubeconfig file for connectivity, but it can also be configured to use certificates.

module "flux_bootstrap" {
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.kind_cluster.kubeconfig
}
```
# Usage

Clone this repository and navigate to its directory:

git clone https://github.com/bartaadalbert/tf-pro
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
