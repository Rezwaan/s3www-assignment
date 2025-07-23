# Deploy the s3www application using Helm
resource "helm_release" "s3www_app" {
  name       = var.release_name
  chart      = "./helm-charts/s3www-app"
  namespace  = kubernetes_namespace_v1.s3www_namespace.metadata[0].name
  version    = var.chart_version

  # Wait for the deployment to be ready
  wait             = true
  timeout          = 600
  create_namespace = false
  
  # Force resource updates if needed
  force_update    = var.force_update
  recreate_pods   = var.recreate_pods
  cleanup_on_fail = true

  # Use the chart's values.yaml directly and override only what's needed
  values = [
    file("${path.module}/helm-charts/s3www-app/values.yaml")
  ]

  # Override specific values through set blocks
  set {
    name  = "global.environment"
    value = var.environment
  }

  depends_on = [
    kubernetes_namespace_v1.s3www_namespace,
    kubernetes_manifest.minio_sealed_secret
  ]
}
