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


variable "config_patches" {
  type = list(any)
}

locals {
  nodes                           = split(",", var.nodes)
  endpoint                        = "${var.cluster_name}.${var.domain_name}"
  kubeconfig                      = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  kubernetes_client_configuration = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration
  config_patches                  = var.config_patches
  talosconfig                     = data.talos_client_configuration.this.talos_config
}
