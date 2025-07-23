# Namespace outputs
output "namespace" {
  description = "The Kubernetes namespace where the application is deployed"
  value       = kubernetes_namespace_v1.s3www_namespace.metadata[0].name
}

# Helm release outputs
output "helm_release_name" {
  description = "The name of the Helm release"
  value       = module.s3www_app.release_name
}

output "helm_release_namespace" {
  description = "The namespace of the Helm release"
  value       = module.s3www_app.release_namespace
}

output "helm_release_version" {
  description = "The version of the deployed Helm release"
  value       = module.s3www_app.release_version
}

output "helm_release_status" {
  description = "The status of the Helm release"
  value       = module.s3www_app.release_status
}

# Service information
output "service_name" {
  description = "The name of the s3www service"
  value       = "${var.release_name}-s3www"
}

output "minio_service_name" {
  description = "The name of the MinIO service"
  value       = "${var.release_name}-minio"
}

# Access information
output "application_url" {
  description = "URL to access the s3www application"
  value       = "http://localhost:8080 (via port-forward)"
}

output "minio_console_url" {
  description = "URL to access the MinIO console"
  value       = "http://localhost:9001 (via port-forward)"
}

output "minio_root_username" {
  description = "Username for MinIO"
  value       = "kubectl get secret -n s3www s3www-app-minio -o jsonpath='{.data.rootUser}' | base64 -d && echo"
}

output "minio_root_password" {
  description = "Username for MinIO"
  value       = "kubectl get secret -n s3www s3www-app-minio -o jsonpath='{.data.rootPassword}' | base64 -d && echo"
}

# Configuration outputs
output "environment" {
  description = "The deployment environment"
  value       = var.environment
}


# Connection commands
output "kubectl_commands" {
  description = "Useful kubectl commands for managing the deployment"
  value = {
    get_pods           = "kubectl get pods -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name}"
    get_services       = "kubectl get services -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name}"
    port_forward       = "kubectl port-forward -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name} svc/${var.release_name}-s3www 8080:8080"
    minio_port_forward = "kubectl port-forward -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name} svc/${var.release_name}-minio 9000:9000 9001:9001"
    logs               = "kubectl logs -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name} -l app.kubernetes.io/name=s3www-app -f"
    describe           = "kubectl describe deployment -n ${kubernetes_namespace_v1.s3www_namespace.metadata[0].name} ${var.release_name}-s3www"
  }
}

# Helm commands
output "helm_commands" {
  description = "Useful Helm commands for managing the release"
  value = {
    status    = "helm status ${module.s3www_app.release_name} -n ${module.s3www_app.release_namespace}"
    history   = "helm history ${module.s3www_app.release_name} -n ${module.s3www_app.release_namespace}"
    upgrade   = "helm upgrade ${module.s3www_app.release_name} ./helm-charts/s3www-app -n ${module.s3www_app.release_namespace}"
    rollback  = "helm rollback ${module.s3www_app.release_name} -n ${module.s3www_app.release_namespace}"
    uninstall = "helm uninstall ${module.s3www_app.release_name} -n ${module.s3www_app.release_namespace}"
  }
}