provider "aws" {
  profile = "personal"
  region  = var.region
}

resource "aws_s3_bucket" "test_lambda_store_s3_bucket" {
  bucket        = var.artifacts_s3_store
  acl           = "private" # or can be "public-read"
  force_destroy = true
}

resource "aws_s3_bucket" "source_lambda_store_s3_bucket" {
  bucket        = var.source_s3_store
  acl           = "private" # or can be "public-read"
  force_destroy = true
}

terraform {
  backend "s3" {
    bucket         = "xlive-bot-terraform-state"
    dynamodb_table = "terraform_locks"
    key            = "dev/terraform.tfstate"
    encrypt        = "true"
    region         = "eu-central-1"
  }
}