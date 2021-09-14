resource "aws_s3_bucket" "test_lambda_store_s3_bucket" {
  bucket        = var.artifacts_s3_store
  acl           = "private" # or can be "public-read"
  force_destroy = true
}