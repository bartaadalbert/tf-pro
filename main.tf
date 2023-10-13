module "k3d_cluster" {

  #K3D CLUSERT KUBECONFIG SOURCE GET
  source            = "github.com/bartaadalbert/tf-k3d-cluster?ref=kubeconfig"

  K3D_CLUSTER_NAME  = var.K3D_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS

}

module "tls_private_key" {
  source    = "github.com/bartaadalbert/tf-tls-keys?ref=master"
  algorithm = "RSA"
}

module "github_repository" {
  source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "terra_deploy_key"
}

module "flux_bootstrap" {

  #KUBECONFIG SOURCE EXAMPLE
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem
  #KUBECONFIG FILE
  config_path       = module.k3d_cluster.kubeconfig

}

  module "argocd_bootstrap" {
      source                  = "github.com/bartaadalbert/tf-argocd-bootstrap?ref=master"
      github_repository       = "${var.GITHUB_OWNER}/${var.ARGO_GITHUB_REPO}"
      private_key             = module.tls_private_key.private_key_pem
      kubeconfig              = module.k3d_cluster.kubeconfig
      app_name                = var.app_name
      destination_namespace   = var.destination_namespace
      project_path            = var.project_path
      project_targetRevision  = var.project_targetRevision
      #pass Argoadmin
      admin_password          = "$2a$12$DM0giBMMw05FA9PeyEjJxuUaVpPx0AeVqxNq.B0jVWGSummn4MthW/n6"
      patch_argocd_password   = true
  }