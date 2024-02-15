locals {
  cp_config_patches = [
    file("../../patches/cilium.yaml"), 
    file("../../patches/pi_storage.yaml")
    ]
}

variable "nodes" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "github_token" {
  sensitive = true
  type      = string
}

variable "github_org" {
  type = string
}

variable "github_repository" {
  type = string
}

module "bootstrap" {
  source            = "../../modules/talos-deploy/"
  cluster_name      = var.cluster_name
  domain_name       = var.domain_name
  github_repository = var.github_repository
  github_token      = var.github_token
  github_org        = var.github_org
  nodes             = var.nodes
  config_patches    = local.cp_config_patches
}
