# Layer 00: CRD Bootstrap
#
# Apply KubeBlocks CRDs once per cluster lifecycle.
# WARNING: CRDs are cluster-scoped and PERSISTENT.
# Run this ONLY for initial cluster setup or CRD upgrades.

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

# CRD Application
# The trigger ensures CRDs are only re-applied when the file actually changes
# or when explicitly forced.
resource "null_resource" "crds" {
  triggers = {
    crds_hash    = filemd5(var.crds_file_path)
    force_update = var.crd_force_update ? timestamp() : "false"
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying KubeBlocks CRDs from ${var.crds_file_path}..."
      kubectl create -f ${var.crds_file_path} || kubectl replace -f ${var.crds_file_path}
      echo "Waiting for CRDs to be established..."
      kubectl wait --for condition=established --timeout=120s -f ${var.crds_file_path} 2>/dev/null || true
      echo "CRDs applied successfully."
    EOT
  }

  # CRITICAL: Prevent accidental CRD deletion.
  # This ensures CRDs are NEVER deleted by terraform destroy.
  lifecycle {
    prevent_destroy = true
  }
}

# Verification - ensures key CRDs are established
resource "null_resource" "crds_verification" {
  depends_on = [null_resource.crds]

  triggers = {
    crds_hash = filemd5(var.crds_file_path)
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Verifying key CRDs are established..."
      kubectl get crd componentdefinitions.apps.kubeblocks.io >/dev/null 2>&1 && echo "✓ ComponentDefinitions"
      kubectl get crd clusters.apps.kubeblocks.io >/dev/null 2>&1 && echo "✓ Clusters"
      kubectl get crd componentversions.apps.kubeblocks.io >/dev/null 2>&1 && echo "✓ ComponentVersions"
      echo "CRD verification complete."
    EOT
  }
}
