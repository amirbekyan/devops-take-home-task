resource "minio_s3_bucket" "postgresql" {
  bucket         = "${local.project}-postgresql"
  acl            = "private"
  object_locking = false
}
