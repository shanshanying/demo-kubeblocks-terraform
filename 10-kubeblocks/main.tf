# Layer 10: KubeBlocks Platform
#
# Install and manage the KubeBlocks platform and addons.
# Depends on: Layer 00 (CRDs)

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
  # Determine if using remote repository or local path
  use_remote_kb   = var.kubeblocks_repository != ""
  use_remote_addon = var.addons_repository != ""
}

# KubeBlocks Core Platform
resource "helm_release" "kubeblocks" {
  name             = "kubeblocks"
  repository       = local.use_remote_kb ? var.kubeblocks_repository : null
  chart            = local.use_remote_kb ? "kubeblocks" : var.kubeblocks_chart_path
  version          = var.kubeblocks_chart_version != "" ? var.kubeblocks_chart_version : null
  namespace        = var.kubeblocks_namespace
  create_namespace = true
  wait             = true
  timeout          = 600

  values = [
    var.kubeblocks_values_file != "" && fileexists(var.kubeblocks_values_file) ? file(var.kubeblocks_values_file) : ""
  ]

  set {
    name  = "image.registry"
    value = var.image_registry
  }

  set {
    name  = "image.repository"
    value = "apecloud/kubeblocks"
  }

  dynamic "set" {
    for_each = var.kubeblocks_version != "" ? [1] : []
    content {
      name  = "image.tag"
      value = var.kubeblocks_version
    }
  }
}

# Addons (ComponentDefinitions)
locals {
  addons_to_install = {
    for addon in var.addons : addon.name => addon
    if addon.enabled
  }
}

resource "helm_release" "addons" {
  for_each = local.addons_to_install

  name             = each.value.name
  repository       = local.use_remote_addon ? var.addons_repository : null
  chart            = local.use_remote_addon ? each.value.name : "${var.addons_path}/${each.value.name}"
  version          = each.value.chart_version != "" ? each.value.chart_version : null
  namespace        = var.kubeblocks_namespace
  create_namespace = false
  wait             = true
  timeout          = 300

  set {
    name  = "extra.keepResource"
    value = each.value.keep_resource
  }

  values = [
    yamlencode(each.value.values)
  ]

  atomic          = true
  cleanup_on_fail = true
}
