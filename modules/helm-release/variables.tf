# modules/helm-release/variables.tf

variable "name" {
  description = "Name of the Helm release"
  type        = string
}

variable "chart" {
  description = "Chart name or path (for local charts, use relative path)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the release"
  type        = string
}

variable "repository" {
  description = "Helm repository URL (optional for local charts)"
  type        = string
  default     = null
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = true
}

variable "wait" {
  description = "Wait for deployment to be ready"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Timeout for deployment in seconds"
  type        = number
  default     = 300
}

variable "cleanup_on_fail" {
  description = "Cleanup resources on failure"
  type        = bool
  default     = true
}

variable "force_update" {
  description = "Force resource updates"
  type        = bool
  default     = false
}

variable "recreate_pods" {
  description = "Recreate pods on upgrade"
  type        = bool
  default     = false
}

variable "replace" {
  description = "Replace the release if it exists"
  type        = bool
  default     = false
}

variable "disable_webhooks" {
  description = "Disable webhooks during installation"
  type        = bool
  default     = false
}

variable "atomic" {
  description = "Enable atomic installation (rollback on failure)"
  type        = bool
  default     = true
}

variable "skip_crds" {
  description = "Skip CRD installation"
  type        = bool
  default     = false
}

variable "values_files" {
  description = "List of values files to use"
  type        = list(string)
  default     = []
}

variable "set_values" {
  description = "Map of values to set"
  type        = map(string)
  default     = {}
}

variable "create_before_destroy" {
  description = "Create new resource before destroying old one"
  type        = bool
  default     = false
}

variable "provisioners" {
  description = "Map of provisioners to run (create/destroy)"
  type = object({
    create_commands  = optional(list(string), [])
    destroy_commands = optional(list(string), [])
  })
  default = {
    create_commands  = []
    destroy_commands = []
  }
}