
resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${local.endpoint}:6443"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches   = local.config_patches
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.nodes
  endpoints            = local.nodes
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.nodes[0]
}

data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.nodes
  control_plane_nodes  = local.nodes
  timeouts = {
    read = "60m"
  }
  depends_on           = [resource.local_sensitive_file.kubeconfig, resource.local_sensitive_file.talosconfig]
}

resource "talos_machine_configuration_apply" "this" {
  count                       = length(local.nodes)
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  node                        = local.nodes[count.index]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.this
  ]
  node                 = local.nodes[0]
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "local_sensitive_file" "kubeconfig" {
  content  = local.kubeconfig
  filename = "configs/${local.endpoint}_kubeconfig.yaml"
}

resource "local_sensitive_file" "talosconfig" {
  content  = local.talosconfig
  filename = "configs/${local.endpoint}_talosconfig.yaml"
}

resource "tls_private_key" "this" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "github_repository_deploy_key" "this" {
  title      = "${var.cluster_name}_FluxCD"
  repository = var.github_repository
  key        = tls_private_key.this.public_key_openssh
  read_only  = "false"
}

resource "flux_bootstrap_git" "this" {
  depends_on = [github_repository_deploy_key.this, data.talos_cluster_health.this]
  path = "clusters/${var.cluster_name}"
}