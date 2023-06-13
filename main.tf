# module "gke_cluster" {
#   source         = "github.com/bartaadalbert/tf-google-gke-cluster"
#   GOOGLE_REGION  = var.GOOGLE_REGION
#   GOOGLE_PROJECT = var.GOOGLE_PROJECT
#   GKE_NUM_NODES  = 3
# }

module "kind_cluster" {

  # source = "github.com/den-vasyliev/tf-kind-cluster"
  source            = "github.com/bartaadalbert/tf-kind-cluster"
  KIND_CLUSTER_NAME = var.KIND_CLUSTER_NAME
  NUM_MASTERS       = var.NUM_MASTERS
  NUM_WORKERS       = var.NUM_WORKERS

}

terraform {
  backend "gcs" {
    bucket = "kbot-bucket"
    prefix = "terraform/state"
  }
}

module "github_repository" {
  source                   = "github.com/den-vasyliev/tf-github-repository"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux1"
}

resource "null_resource" "wait_for_kind_config" {
  depends_on = [module.kind_cluster]

  provisioner "local-exec" {
    command = <<-EOT
      while [ ! -f ${module.kind_cluster.kubeconfig} ]; do
        echo "Waiting for kind-config to be created..."
        sleep 2
      done
    EOT
    interpreter = ["bash", "-c"]
  }
}

module "flux_bootstrap" {
  # source            = "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap"
  source            = "github.com/bartaadalbert/tf-fluxcd-flux-bootstrap"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_path       = module.kind_cluster.kubeconfig
  dummy_input       = null_resource.wait_for_kind_config.id
}
module "tls_private_key" {
  source    = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}