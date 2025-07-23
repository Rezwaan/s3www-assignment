# modules/helm-release/main.tf

resource "helm_release" "this" {
  name         = var.name
  chart        = var.chart
  namespace    = var.namespace
  repository   = var.repository
  
  # Lifecycle management
  wait                = var.wait
  timeout             = var.timeout
  create_namespace    = var.create_namespace
  cleanup_on_fail     = var.cleanup_on_fail
  force_update        = var.force_update
  recreate_pods       = var.recreate_pods
  replace             = var.replace
  disable_webhooks    = var.disable_webhooks
  atomic              = var.atomic
  skip_crds           = var.skip_crds

  # Values files
  values = var.values_files

  # Set regular values
  dynamic "set" {
    for_each = var.set_values
    content {
      name  = set.key
      value = set.value
    }
  }
}