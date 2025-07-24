# Create namespace for the application
resource "kubernetes_namespace_v1" "s3www_namespace" {
  depends_on = [module.sealed_secrets]
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "s3www-app"
      "app.kubernetes.io/managed-by" = "terraform"
      "environment"                  = var.environment
    }
    annotations = {
      "description" = "Namespace for s3www application and MinIO storage"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}