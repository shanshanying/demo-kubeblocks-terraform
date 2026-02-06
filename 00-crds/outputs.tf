# Outputs: CRD Bootstrap Layer

output "crds_hash" {
  description = "MD5 hash of the CRD file (for tracking purposes)"
  value       = filemd5(var.crds_file_path)
}

output "crds_file_path" {
  description = "Path to the applied CRD file"
  value       = var.crds_file_path
}

output "note" {
  description = "Important note about CRD management"
  value       = "CRDs have been applied. These are cluster-scoped resources that persist beyond this Terraform workspace."
}
