locals {
  project        = "devops-task"
  cluster_domain = "devops.task"
  region         = "nbg1"
  s3_host        = format("%s.%s", local.region, "your-objectstorage.com")
  s3_endpoint    = "https://${local.s3_host}"
  github_slug    = "getnickai/take-home-devops-task-m"
  github_repo    = "https://github.com/${local.github_slug}.git"
  github_cr      = "ghcr.io/${local.github_slug}"
  environments = {
    staging = {
      namespace       = "${local.project}-staging"
      database        = "devops_task_staging"
      db_user         = "api"
      image           = "${local.github_cr}:latest"
      update_strategy = "digest"
      allow_tags      = "any"
    }
    production = {
      namespace       = "${local.project}-production"
      database        = "devops_task_production"
      db_user         = "api"
      image           = local.github_cr
      update_strategy = "newest-build"
      allow_tags      = "regexp:^v[0-9]+\\.[0-9]+\\.[0-9]+$"
    }
  }
}
