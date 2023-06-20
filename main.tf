module "gke_cluster" {
  source         = "github.com/bartaadalbert/tf-google-gke-cluster?ref=kubeconfig"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 3
}


terraform {
  backend "gcs" {
    bucket = "kbot-bucket"
    prefix = "terraform/state"
  }
}

module "github_repository" {
  source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux1"
}

module "flux_bootstrap" {
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.gke_cluster.kubeconfig_path
}

module "tls_private_key" {
  source    = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}