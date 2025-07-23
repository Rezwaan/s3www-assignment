# Kubernetes configuration
variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kube_context" {
  description = "Kubernetes context to use"
  type        = string
  default     = "docker-desktop"
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "s3www"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.namespace))
    error_message = "Regex used for correct naming convention for the namespace."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# Helm configuration
variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "s3www-app"
  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?$", var.release_name))
    error_message = "Regex used for correct release name."
  }
}

variable "chart_version" {
  description = "Version of the Helm chart"
  type        = string
  default     = "0.1.0"
}

variable "force_update" {
  description = "Force resource updates through replacement"
  type        = bool
  default     = false
}

variable "recreate_pods" {
  description = "Perform pods restart during upgrade/rollback"
  type        = bool
  default     = false
}
