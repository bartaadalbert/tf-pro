module "kind_cluster" {

  #KIND CLUSERT KUBECONFIG SOURCE GET
  source            = "github.com/bartaadalbert/tf-kind-cluster"

  KIND_CLUSTER_NAME = var.KIND_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS

}

module "tls_private_key" {
  source    = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}

module "github_repository" {
  source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux_deploy_key"
}

module "flux_bootstrap" {

  #KUBECONFIG SOURCE EXAMPLE
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem

  #KUBECONFIG FILE
  config_path       = module.kind_cluster.kubeconfig

}

