terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.2.2"
    }
    github = {
      source  = "integrations/github"
      version = ">=5.18.0"
    }
  }
}

provider "flux" {
  kubernetes = {
    host                   = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    client_certificate     = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  }
  git = {
    url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
    ssh = {
      username    = "git"
      private_key = tls_private_key.this.private_key_openssh
    }
  }
}

provider "github" {
  owner = var.github_org
  token = var.github_token
}
