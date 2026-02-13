resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = "argo-cd"
  }
}

resource "helm_release" "argo_cd" {
  name       = "argo-cd"
  namespace  = kubernetes_namespace.argo_cd.id
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "9.2.2"

  values = [
    templatefile("${path.module}/src/helm/helm-values-argo-cd.yml", {
      env                     = local.env
      hostname                = "argo-cd.devops.task"
      dex_image               = "v2.44.0"
      redis_image             = "8.2.2-alpine"
      redis_exporter          = "v1.80.1"
      extensions_installer    = "v0.0.9"
      argo_rollouts_extension = "v0.3.7"
      config_repositories = indent(4, yamlencode({
        git = {
          type     = "git"
          name     = "devops-task"
          url      = "https://github.com/getnickai/take-home-devops-task-m.git"
          username = var.github.user
          password = var.github.pat
        }
      }))
      extensions_enabled    = true
      admin_enabled         = false
      status_badge_enabled  = true
      notifications_enabled = true
      dex_enabled           = false
      webhook_url           = var.webhook_url
      log_format            = "json"
      log_level             = "warn"
      prometheus_enabled    = true
      prometheus_labels = indent(8, yamlencode({
        release = "prometheus"
      }))
    })
  ]
}
