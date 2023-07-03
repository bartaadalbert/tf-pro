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

module "gke-workload-identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  name                = "kustomize-controller"
  namespace           = "flux-system"
  project_id          = var.GOOGLE_PROJECT
  location            = var.GOOGLE_REGION
  cluster_name        = "main"
  annotate_k8s_sa     = true
  use_existing_k8s_sa = true
  roles               = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
}

module "kms" {
  source          = "github.com/den-vasyliev/terraform-google-kms"
  project_id      = var.GOOGLE_PROJECT
  location        = "global"
  keyring         = "sops-flux-1"
  keys            = ["sops-key-flux-1"]
  prevent_destroy = false
}

resource "local_file" "secret_manifest" {
  for_each = {
    kbot = { telegramToken = var.TG_BOT_TOKEN }
  }

  filename = "${each.key}.yaml"
  content  = templatefile("${each.key}.yaml.tpl", {
    secret_data = {
      for k, v in each.value :
      k => base64encode(v)
    }
  })

  provisioner "local-exec" {
    command = <<EOF
      command -v sops >/dev/null 2>&1 || \
      (echo "SOPS is not installed. Installing..." && \
      sudo curl -L -o /usr/local/bin/sops \
      https://github.com/getsops/sops/releases/download/${var.sops_version}/sops-${var.sops_version}.${var.sops_os}.${var.sops_arch} && \
      sudo chmod +x /usr/local/bin/sops)
    EOF
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    command     = "sops -e --gcp-kms projects/${var.GOOGLE_PROJECT}/locations/global/keyRings/${var.kms_key_ring}/cryptoKeys/${var.kms_crypto_key} --encrypted-regex '^(telegramToken)$' ${each.key}.yaml > ${each.key}-enc.yaml"
    interpreter = ["bash", "-c"]
  }
}

locals {
  gitignore_filenames = [for f in local_file.secret_manifest : f.filename]
}

resource "null_resource" "gitignore_append" {
  provisioner "local-exec" {
    command = <<EOF
      if ! grep -q -x -F '${join("\n", local.gitignore_filenames)}' .gitignore; then
        echo -e '\n# Automatically generated secrets\n${join("\n", local.gitignore_filenames)}' >> .gitignore
      fi
    EOF
    interpreter = ["bash", "-c"]
  }

}


#!!!!!!!!NOT READY BUT I NEED LIKE THAT!!!!!!!!
# module "my_secrets" {
#   source        = "github.com/bartaadalbert/kubernetes-secrets-sops"
#   secrets       = {
#     kbot = {
#       tokenKey  = var.TG_BOT_TOKEN
#     }
#   }
#   namespace     = var.namespace
#   gcp_project   = var.GOOGLE_PROJECT
#   kms_key_ring  = var.kms_key_ring
#   kms_crypto_key = var.kms_crypto_key
# }