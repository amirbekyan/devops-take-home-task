locals {
  env            = "devops-task"
  cluster_domain = "devops.task"
  region         = "nbg1"
  s3_host        = format("%s.%s", local.region, "your-objectstorage.com")
  s3_endpoint    = "https://${local.s3_host}"
}
