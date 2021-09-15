variable "lambda_filler_name" {
  type    = string
  default = "xlive-price-filler"
}
variable "lambda_bot_name" {
  type    = string
  default = "xlive-price-bot"
}

variable "artifacts_s3_store" {
  type    = string
  default = "xlive-bot-artifacts-s3-store"
}

variable "source_s3_store" {
  type    = string
  default = "xlive-bot-source-s3-store"
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "github_owner" {
  type    = string
  default = "alexandrostriviany"
}

variable "branch" {
  type    = string
  default = "main"
}