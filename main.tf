module "kind_cluster" {

  #KIND CLUSTER CERTS SOURCE GET
  source            = "github.com/bartaadalbert/tf-kind-cluster?ref=cert"

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

  #KIND CERTS SOURCE EXAMPLE
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap?ref=kind"

  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  github_token      = var.GITHUB_TOKEN
  private_key       = module.tls_private_key.private_key_pem

  #KIND CERTS SOURCE
  config_host       = module.kind_cluster.endpoint
  config_client_key = module.kind_cluster.client_key
  config_ca         = module.kind_cluster.ca
  config_crt        = module.kind_cluster.crt
}

