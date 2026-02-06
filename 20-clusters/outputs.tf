# Outputs: Database Clusters Layer

output "cluster_names" {
  description = "Names of deployed clusters"
  value       = [for name, release in helm_release.clusters : release.name]
}

output "cluster_info" {
  description = "Detailed information about deployed clusters"
  value = {
    for name, release in helm_release.clusters : name => {
      name      = release.name
      namespace = release.namespace
      status    = release.status
      engine    = var.clusters[name].engine
      version   = var.clusters[name].version
    }
  }
}

output "kubectl_commands" {
  description = "Useful kubectl commands"
  value       = <<-EOT
# List all KubeBlocks clusters
kubectl get cluster -A

# Check cluster details
%{for name, cluster in helm_release.clusters~}
kubectl describe cluster ${cluster.name} -n ${cluster.namespace}
%{endfor}

# Check pods
%{for name, cluster in helm_release.clusters~}
kubectl get pods -n ${cluster.namespace} -l app.kubernetes.io/instance=${cluster.name}
%{endfor}
  EOT
}
