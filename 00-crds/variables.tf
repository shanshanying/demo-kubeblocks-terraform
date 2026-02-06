# Variables: CRD Bootstrap Layer

variable "crds_file_path" {
  description = "Path to the KubeBlocks CRD YAML file"
  type        = string
  default     = "../data/101_crds.yaml"
}

variable "crd_force_update" {
  description = "Force CRD re-application even if file hasn't changed. Use when upgrading KubeBlocks versions."
  type        = bool
  default     = false
}
