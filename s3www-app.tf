module "s3www_app" {
  source = "./modules/helm-release"

  name      = var.release_name
  chart     = "./helm-charts/s3www-app"
  namespace = kubernetes_namespace_v1.s3www_namespace.metadata[0].name

  # Configuration
  wait             = true
  timeout          = 600
  create_namespace = false
  force_update     = var.force_update
  recreate_pods    = var.recreate_pods

  # Values file
  values_files = [
    file("${path.module}/helm-charts/s3www-app/values.yaml")
  ]

  # Set values
  set_values = {
    "global.environment" = var.environment
  }

  # Lifecycle management
  create_before_destroy = true

  # Dependencies
  depends_on = [
    kubernetes_namespace_v1.s3www_namespace,
    kubernetes_manifest.minio_sealed_secret
  ]
}
