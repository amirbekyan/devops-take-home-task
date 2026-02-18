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
      project                 = local.project
      hostname                = "argo-cd.devops.task"
      dex_image               = "v2.44.0"
      redis_image             = "8.2.2-alpine"
      redis_exporter          = "v1.80.1"
      extensions_installer    = "v0.0.9"
      argo_rollouts_extension = "v0.3.7"
      config_repositories = indent(4, yamlencode({
        git = {
          type     = "git"
          name     = local.project
          url      = local.github_repo
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

resource "helm_release" "argo_cd_image_updater" {
  name       = "argo-cd-image-updater"
  namespace  = kubernetes_namespace.argo_cd.id
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater"
  version    = "1.1.0"

  values = [
    templatefile("${path.module}/src/helm/helm-values-argo-cd-image-updater.yml", {
      registries = indent(4, yamlencode([
        {
          name    = local.project
          api_url = "https://ghcr.io"
          prefix  = "ghcr.io"
          ping    = false
          credentials = format("secret:%s/%s#token",
            kubernetes_namespace.argo_cd.id,
            kubernetes_secret.ghcr_auth_credentials.metadata[0].name
          )
      }]))
      prometheus_enabled = true
      prometheus_labels = indent(6, yamlencode({
        release = "prometheus"
      }))
      }
    )
  ]
}

resource "kubernetes_secret" "ghcr_auth_credentials" {
  metadata {
    name      = "ghcr-auth"
    namespace = kubernetes_namespace.argo_cd.id
  }
  data = {
    token = "${var.github.user}:${var.github.pat}"
  }
}
