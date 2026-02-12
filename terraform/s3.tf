resource "minio_s3_bucket" "postgresql" {
  bucket         = "${local.env}-postgresql"
  acl            = "private"
  object_locking = false
}
