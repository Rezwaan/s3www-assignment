# modules/helm-release/outputs.tf

output "release_name" {
  description = "Name of the Helm release"
  value       = helm_release.this.name
}

output "release_namespace" {
  description = "Namespace of the Helm release"
  value       = helm_release.this.namespace
}

output "release_version" {
  description = "Version of the Helm release"
  value       = helm_release.this.version
}

output "release_status" {
  description = "Status of the Helm release"
  value       = helm_release.this.status
}

output "release_chart" {
  description = "Chart used for the Helm release"
  value       = helm_release.this.chart
}

output "release_values" {
  description = "Values used for the Helm release"
  value       = helm_release.this.values
  sensitive   = true
}