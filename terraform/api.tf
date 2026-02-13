locals {
  environments = {
    staging = {
      namespace = "devops-task-staging"
      database  = "devops_task_staging"
      db_user   = "api"
    }
    production = {
      namespace = "devops-task-production"
      database  = "devops_task_production"
      db_user   = "api"
    }
  }
  shared_parameter_overrides = [
    {
      name = "postgresql.host"
      value = format("%s-%s.%s",
        kubernetes_manifest.devops_task_postgresql.object.metadata.name,
        "pooler",
        kubernetes_namespace.postgres.id
      )
    },
    {
      name  = "postgresql.port"
      value = "5432"
    },
    {
      name  = "postgresql.sslmode"
      value = "require"
    },
    {
      name  = "postgresql.validateCa"
      value = "false"
    }
  ]
}

resource "kubernetes_namespace" "devops_task" {
  for_each = local.environments
  metadata {
    name = each.value.namespace
  }
}

resource "kubernetes_secret" "devops_task_img_pull_ghcr" {
  for_each = kubernetes_namespace.devops_task
  metadata {
    name      = "img-pull-token-ghcr"
    namespace = each.value.id
  }
  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          "username" = var.github.user
          "password" = var.github.pat
        }
      }
    })
  }
}

resource "helm_release" "devops_task_api" {
  for_each   = local.environments
  name       = "devops-task-api-${each.key}"
  namespace  = kubernetes_namespace.devops_task[each.key].id
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = "2.0.3"

  values = [
    templatefile("${path.module}/src/helm/helm-values-argocd-apps.yml", {
      app_name     = "devops-task-api-${each.key}"
      project_name = each.key
      source_repo  = "https://github.com/getnickai/take-home-devops-task-m.git"
      # source_revision = "HEAD"
      source_revision = "amir.part4"
      source_path     = "k8s/charts/devops-api"
      app_ns          = kubernetes_namespace.argo_cd.id
      destination_ns  = kubernetes_namespace.devops_task[each.key].id
      sync_options = indent(8, yamlencode([
        "CreateNamespace=false",
        "ServerSideApply=true"
      ]))
      revision_history = 5
      extra_values_files = indent(10, yamlencode([
        "values-${each.key}.yaml"
      ]))
      parameters = indent(10, yamlencode(concat(local.shared_parameter_overrides, [
        {
          name  = "postgresql.database"
          value = each.value.database
        },
        {
          name = "postgresql.secret.name"
          value = format("%s.%s.%s.pg-credentials",
            kubernetes_namespace.devops_task[each.key].id,
            "api",
            kubernetes_manifest.devops_task_postgresql.object.metadata.name
          )
        },
        {
          name  = "imagePullSecrets[0].name"
          value = kubernetes_secret.devops_task_img_pull_ghcr[each.key].metadata[0].name
        }
      ])))
      info = indent(6, yamlencode([
        {
          name  = "env"
          value = each.key
        }
      ]))
    })
  ]
}
