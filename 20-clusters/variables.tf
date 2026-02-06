# Variables: Database Clusters Layer

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "clusters_repository" {
  description = "Helm repository URL for cluster charts. Leave empty to use local chart paths."
  type        = string
  default     = ""
}

variable "addons_cluster_path" {
  description = "Local path to addons-cluster directory. Used when repository is not set."
  type        = string
  default     = "../../addons-cluster"
}

variable "clusters" {
  description = "Map of database clusters to deploy"
  type = map(object({
    name               = string
    engine             = string
    namespace          = string
    version            = string
    replicas           = number
    cpu                = number
    memory             = number
    storage            = number
    chart_version      = optional(string, "")
    topology           = optional(string, "")
    termination_policy = optional(string, "Delete")
    values_file        = optional(string, "")
    extra_values       = optional(map(string), {})
    enabled            = optional(bool, true)
  }))
  default = {}
}
