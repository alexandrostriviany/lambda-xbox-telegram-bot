provider "aws" {
  region  = var.region
}

data "aws_ssm_parameter" "token" {
  name = "/XlivePriceBot/token"
}

data "aws_ssm_parameter" "name" {
  name = "/XlivePriceBot/name"
}

data "aws_ssm_parameter" "path" {
  name = "/XlivePriceBot/apiPath"
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