module "k3d_cluster" {

  #K3D CLUSERT KUBECONFIG SOURCE GET
  source            = "github.com/bartaadalbert/tf-k3d-cluster?ref=kubeconfig"

  K3D_CLUSTER_NAME  = var.K3D_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS

}

# module "tls_private_key" {
#   source    = "github.com/bartaadalbert/tf-tls-keys?ref=master"
#   algorithm = "RSA"
# }

# module "github_repository" {
#   source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
#   github_owner             = var.GITHUB_OWNER
#   github_token             = var.GITHUB_TOKEN
#   repository_name          = var.FLUX_GITHUB_REPO
#   public_key_openssh       = module.tls_private_key.public_key_openssh
#   public_key_openssh_title = "flux_deploy_key"
# }


module "tls_private_key_argo" {
  source    = "github.com/bartaadalbert/tf-tls-keys?ref=master"
  algorithm = "RSA"
}

module "github_repository_argo" {
  source                   = "github.com/bartaadalbert/tf-github-repository?ref=develop"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.ARGO_GITHUB_REPO
  public_key_openssh       = module.tls_private_key_argo.public_key_openssh
  public_key_openssh_title = "argo_deploy_key"
}


# module "flux_bootstrap" {

#   #KUBECONFIG SOURCE EXAMPLE
#   source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
#   github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
#   github_token      = var.GITHUB_TOKEN
#   private_key       = module.tls_private_key.private_key_pem
#   #KUBECONFIG FILE
#   config_path       = module.k3d_cluster.kubeconfig

# }

module "argocd_bootstrap" {
  source                  = "github.com/bartaadalbert/tf-argocd-bootstrap?ref=master"
  github_repository       = "${var.GITHUB_OWNER}/${var.ARGO_GITHUB_REPO}"
  private_key             = module.tls_private_key_argo.private_key_pem
  kubeconfig              = module.k3d_cluster.kubeconfig
  app_name                = var.app_name
  destination_namespace   = var.destination_namespace
  project_path            = var.project_path
  project_targetRevision  = var.project_targetRevision
  #pass Argoadmin
  admin_password          = "$2a$12$DM0giBMMw05FA9PeyEjJxuUaVpPx0AeVqxNq.B0jVWGSummn4MthW/n6"

  #We can add cert-mager to argcd and create the issuer
  patch_argocd_password   = true
  patch_ports             = true
  install_cert_manager    = true
  create_cluster_issuer   = true
  acme_email              = "admin@mydomain.com"
}

module "sealed_secrets" {
  source = "github.com/bartaadalbert/tf-sealed-secrets"
  config_path             = module.k3d_cluster.kubeconfig
  namespace               = var.destination_namespace
  secrets                 = var.secrets
  rsa_bits                = var.rsa_bits
}

module "godaddy_dns" {
  source         = "git@github.com:bartaadalbert/tf-godaddy-A-module"
  gdd_access_key = var.gdd_access_key
  gdd_secret_key = var.gdd_secret_key
  domain         = var.domain
  subdomain_list = var.subdomain_list
  public_ip      = "" # Leave empty to auto-fetch current public IP
}

module "multi_host_ingress" {
  source = "github.com/bartaadalbert/tf-multi-host-ingress"

  kubeconfig        = module.k3d_cluster.kubeconfig
  hosts_to_services = var.hosts_to_services
  annotations       = var.annotations
}

provider "kubectl" {
  config_path = module.k3d_cluster.kubeconfig
}

resource "kubectl_manifest" "apply_sealed_secrets" {
  depends_on = [module.sealed_secrets]
  yaml_body  = module.sealed_secrets.all_encrypted_secrets
}

#You can store this file in public
resource "local_file" "encrypted_secrets_file" {
  depends_on = [module.sealed_secrets]
  content    = module.sealed_secrets.all_encrypted_secrets
  filename   = "${path.module}/all-encrypted-secrets.yaml"
}

#Generated ingress files
resource "local_file" "ingress_output_file" {
  depends_on = [module.multi_host_ingress]
  content    = module.multi_host_ingress.all_ingress_output_yaml
  filename   = "${path.module}/all-ingress-output.yaml"
}

#Share this public key for others to encrypt data with kubeseal
resource "local_file" "sealed_secrets_file" {
  depends_on = [module.sealed_secrets]
  content    = module.sealed_secrets.public_key_pem
  filename   = "${path.module}/public.pem"
}

#Argo admin random pass, patch_argocd_password = false"
resource "local_file" "argo_admin_pass" {
  depends_on = [module.argocd_bootstrap]
  content    = module.argocd_bootstrap.argo_admin_pass
  filename   = "${path.module}/argo-admin-pass.txt"
}
