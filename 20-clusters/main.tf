# Layer 20: Database Clusters
#
# Deploy and manage actual database clusters.
# Depends on: Layer 00 (CRDs), Layer 10 (Platform + Addons)

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

locals {
  use_remote = var.clusters_repository != ""

  enabled_clusters = {
    for name, cluster in var.clusters : name => cluster
    if cluster.enabled
  }
}

# Database Clusters
resource "helm_release" "clusters" {
  for_each = local.enabled_clusters

  name             = each.value.name
  repository       = local.use_remote ? var.clusters_repository : null
  chart            = local.use_remote ? "${each.value.engine}-cluster" : "${var.addons_cluster_path}/${each.value.engine}"
  version          = each.value.chart_version != "" ? each.value.chart_version : null
  namespace        = each.value.namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  # Core settings
  set {
    name  = "version"
    value = each.value.version
  }

  set {
    name  = "replicas"
    value = each.value.replicas
  }

  set {
    name  = "cpu"
    value = each.value.cpu
  }

  set {
    name  = "memory"
    value = each.value.memory
  }

  set {
    name  = "storage"
    value = each.value.storage
  }

  dynamic "set" {
    for_each = each.value.topology != "" ? [each.value.topology] : []
    content {
      name  = "topology"
      value = set.value
    }
  }

  set {
    name  = "extra.terminationPolicy"
    value = each.value.termination_policy
  }

  # Additional custom values
  dynamic "set" {
    for_each = each.value.extra_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
