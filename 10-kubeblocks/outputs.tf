# Outputs: KubeBlocks Platform Layer

output "kubeblocks_namespace" {
  description = "Namespace where KubeBlocks is installed"
  value       = helm_release.kubeblocks.namespace
}

output "kubeblocks_release_version" {
  description = "Revision of the KubeBlocks Helm release"
  value       = helm_release.kubeblocks.metadata[0].revision
}

output "installed_addons" {
  description = "List of installed addon names"
  value       = [for name, release in helm_release.addons : name]
}

output "addon_releases" {
  description = "Map of addon names to their release versions"
  value = {
    for name, release in helm_release.addons : name => release.metadata[0].revision
  }
}

output "platform_status" {
  description = "Platform status summary"
  value       = <<-EOT
KubeBlocks Platform: ${helm_release.kubeblocks.status}
Installed Addons: ${length(helm_release.addons)}

Useful commands:
  kubectl get pods -n ${helm_release.kubeblocks.namespace}
  kubectl get cmpd -n ${helm_release.kubeblocks.namespace}
  EOT
}
