# Deploy Sealed Secrets Controller first
resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  namespace  = "kube-system"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  version    = "2.10.0"

  # Lifecycle management, Since its a managed chart, we need to make sure we have more control on deployment, CRDs and webhooks
  wait                = true
  timeout             = 300
  create_namespace    = true
  cleanup_on_fail     = true
  replace             = var.force_update
  disable_webhooks    = false
  atomic              = true  # Ensures rollback on failure
  skip_crds           = false # Ensure CRDs are managed

  # Lifecycle hooks
  provisioner "local-exec" {
    when    = create
    command = "echo 'Sealed Secrets Controller deployed successfully'"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "echo 'Cleaning up Sealed Secrets Controller'"
  }
}

# Actual Sealed Secret
resource "kubernetes_manifest" "minio_sealed_secret" {
  manifest = yamldecode(<<EOF
  apiVersion: bitnami.com/v1alpha1
  kind: SealedSecret
  metadata:
    name: s3www-app-minio
    namespace: s3www
  spec:
    encryptedData:
      rootUser: AgCzDcjYPi3YV7PUs8XmMAzx/PnN6CrqqV8do39Bq9baMm4i2WNcdc6LVc1QH9rcWHJwanFNC+y6xzQ26UH3IfnHovM0Dxqodg1TY7vGDxLoWIM6FW3nseN9iNgdpsrKp0EsJ1PF7P14+Z0d8p68xBSoiPIGuJJEOok2KHDbpQZIWTSx9y6zi+IhFRQPv3tioR0JOt7fjQious57KuOxGV0zdFwGzj/HYNhURBCjp58gVIpJB4xRMfgA9j/JLCchjj2vd6nGFbZlx582zryYazFYxUrZFLk9NMZ2dZr8GH982r3KL5Z0lF3OufORAtd+7XbJ71VudC97BkJYBSMLKD2bMpxtVUZyL8/3aPJ0NX810KuxjEzMxhiAtIA4RVulYVJOmZ+oBksH2KhQgxF+80BTzxZzmTYtKUM6tgcva7yLJLAqPn7TD2/LQh86Z2UplpMRAL711+gQANZlhTDywNKIgsG8HrsCRmnT46/t+9dpSBRXK5ZswD9B01HrmZO5jkjZmrIZ7LUKgkMCR/7gHPd5/40Yr78O6ECCcfSenLIjZiyAKavVqv/vkoUF75Elh5f/QEzRMJZOjWfL8/y5vs6Qoa9e/HnhYOpe4P3S5nsYLcUhIi6qJ1yMOpGVoBJGN59ktYj0++8mxxa9qNueml4rDwiQmIkJQMn3Lx6qlaZ95W+FUVC4K4lJcXfKbyLAdnJK2WFuCA==
      rootPassword: AgABBb/aGKYppn2TH0hmCvqLMPzhEMpgjhl8x5mH/W8z5ZyLLRoY9eJ0nbZ20hD10SPiOeHJsK1YA2GYxyRd+oCgKX8NjChgP7oZIJcKrIim054uACGJTzh025NA0xYuTOLwcJm3ESURfCYOYeabuJUZ18rRrC6No5si/dDxSm6p0JCKRkHpFRb37ogsEDlD61ZheZZLnJT8I8fgh8eoOrPDfbQ/3WzzVyPZyrDJTz6asAAAeDgHa4CZLHQUKEb4Gh4HCrik7jWsY2uTSTgllLMySTFqcCWqRmxbKMlmuMw2Xi+e546DB63Q9UQbffVsd9KvEmcx9PxyhARPJBDtQ/kRKQW2iSEQpQ0r8CFKCKxmd78uD6eWMmtYmWGK5U7fZXIwozWO4wyU51FU9e9S7GMxrcFgCfzqeQ1Ae/wrwlzTSt7lpLEe01YIvwIp3N434CmVDMukXCbXmeZCsUY8ynMLAN5CmWvapSsrnh40HDbO+01ZG4Cqr/42hVv4MIyoUtKFTuEaLuWLub77z6+UZEF3TSL1vI52Ev2b1n4Skyvv5m+u1eWwfuHcl6JSBsFt/fpbs0SGltv2j7O1Mf9X3kBsW/lgctCZ7b63UUccO9/VnDoiJPgw59E2+VM2Wqbma0kf0LFgaI6rrxyDnmio7OwqZIEJsIjnTUuR/3t98qXepedJIvA3u0Wn/dZicbc55+52TMBqaN/yL+om4w==
    template:
      metadata:
        annotations:
          sealedsecrets.bitnami.com/managed: "true"
        name: s3www-app-minio
        namespace: s3www
      type: Opaque
  EOF
    )
  
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [kubernetes_namespace_v1.s3www_namespace]
}