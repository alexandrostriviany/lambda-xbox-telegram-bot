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

resource "aws_ssm_parameter" "base_url" {
  name        = "/XlivePriceBot/base_url"
  description = "Api GW base url"
  type        = "SecureString"
  value       = "${aws_api_gateway_deployment.bot-api-deployment.invoke_url}/${aws_api_gateway_resource.resource.path_part}"


tags = {
    environment = "production"
  }
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