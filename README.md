# Terraform GitOps Infrastructure: Kind, K3D, Flux, ArgoCD, GitHub, Sealed Secrets, Cert Manager, and Cluster Ingress Issuer

## Video Link
[Watch the video here](https://veed.io/view/1ecb8011-85d4-4fe6-9fd6-b7b312c0f9f1)

## Note
This project was originally cloned from [this repository](https://github.com/gigo6000/quiz.git) to test and validate my module. Everything is working as expected!


This module allows you to set up a Kubernetes environment with ArgoCD for GitOps deployment, complete with Sealed Secrets for secret management, Cert Manager for certificate management, and Cluster Ingress Issuer for domain routing. It offers an end-to-end solution, from deploying applications using Helm to handling ingress resources seamlessly.

## Prerequisites

- **Virtual Private Server (VPS)**
  - At least 2 CPUs
  - At least 4 GB RAM
  - At least 20 GB SSD
  
  > **Recommendation:** Consider using [Netx](https://netx.com.ua/aff.php?aff=456), which offers VPS SSD starting at 5.83$ per month, including KVM and 1 Gbps shared bandwidth.

- **Private GitHub Repository** with:
  - Your application's Helm chart
  - A build system (preferably a Makefile)
  - A private Docker image registry

- **GoDaddy Domain Registration**:
  - GoDaddy access key
  - GoDaddy secret key

## Quick Start

1. **VPS Setup**: Procure a VPS, preferably from [Netx](https://netx.com.ua/aff.php?aff=456).

2. **Repository Preparation**: Ensure your private repository contains the necessary Helm charts. If leveraging a build system, set up a Makefile or an equivalent.

3. **Clone and Navigate to the Module**:

   ```bash
   git clone -b argocd https://github.com/bartaadalbert/tf-pro
   cd tf-pro
   ```

4. **Edit Configuration**:

   Update the provided variables according to your setup.

   ```hcl
   module "k3d_cluster" {
     source            = "github.com/bartaadalbert/tf-k3d-cluster?ref=kubeconfig"
     K3D_CLUSTER_NAME  = var.K3D_CLUSTER_NAME
     NUM_MASTERS       = var.NUM_MASTERS
     NUM_WORKERS       = var.NUM_WORKERS
   }
   ```

   Make sure to adjust other module configurations as necessary.

5. **Initialize and Deploy with Terraform**:

   ```bash
   terraform init
   terraform apply
   ```

6. **Deployment Verification**: After Terraform completes, ensure your application is available through the configured domain.

7. **Secrets Management with Sealed Secrets**: Use Sealed Secrets for Kubernetes secrets. They're encrypted and can be stored securely in version control.

## Important Notes

- Confirm your VPS adheres to the recommended specifications.
- ArgoCD ensures your Kubernetes state aligns with the Git repository's desired state.
- Sealed Secrets help encrypt Kubernetes secrets, ensuring their safe storage in version control.
- The included ingress module assists in domain routing for service accessibility.
- Provide necessary variables such as `GITHUB_OWNER`, `GITHUB_TOKEN`, and others as needed.
  
  If opting for certificates over a kubeconfig file, uncomment the relevant sections in the `k3d_cluster` and other pertinent modules.

## Contributions

Contributions are welcome! If you encounter any issues or have ideas for improvements, feel free to open an issue or submit a pull request.

## License

Licensed under the MIT License.
