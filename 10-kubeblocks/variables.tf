# Variables: KubeBlocks Platform Layer

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

# KubeBlocks Core
variable "kubeblocks_repository" {
  description = "Helm repository URL for KubeBlocks. Leave empty to use local chart path."
  type        = string
  default     = ""
}

variable "kubeblocks_chart_path" {
  description = "Local path to KubeBlocks Helm chart. Used when repository is not set."
  type        = string
  default     = "../../kubeblocks"
}

variable "kubeblocks_chart_version" {
  description = "KubeBlocks Helm chart version. Leave empty for latest."
  type        = string
  default     = ""
}

variable "kubeblocks_namespace" {
  description = "Namespace for KubeBlocks installation"
  type        = string
  default     = "kb-system"
}

variable "kubeblocks_values_file" {
  description = "Path to custom values file for KubeBlocks"
  type        = string
  default     = ""
}

variable "kubeblocks_version" {
  description = "KubeBlocks image version (tag). Leave empty for chart default."
  type        = string
  default     = ""
}

variable "image_registry" {
  description = "Container image registry"
  type        = string
  default     = "docker.io"
}

# Addons
variable "addons_repository" {
  description = "Helm repository URL for addons. Leave empty to use local chart paths."
  type        = string
  default     = ""
}

variable "addons_path" {
  description = "Local path to addons directory. Used when repository is not set."
  type        = string
  default     = "../../addons"
}

variable "addons" {
  description = "List of addons to install. Each addon defines a database engine capability."
  type = list(object({
    name          = string
    enabled       = bool
    chart_version = optional(string, "")
    keep_resource = optional(bool, true)
    values        = optional(map(any), {})
  }))
  default = []
}
