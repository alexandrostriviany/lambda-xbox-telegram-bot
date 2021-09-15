variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "lambda_filler_name" {
  type    = string
  default = "xlive-price-filler"
}

variable "lambda_bot_name" {
  type    = string
  default = "xlive-price-bot"
}

variable "iam-role-name" {
  type    = string
  default = "xlive-price"
}

variable "schedule-parameter" {
  type    = string
  default = "cron(15,45 5-22 * * ? *)"
}

variable "artifacts_s3_store" {
  type    = string
  default = "xlive-bot-artifacts-s3-store"
}

variable "source_s3_store" {
  type    = string
  default = "xlive-bot-source-s3-store"
}
variable "PRICE_TABLE" {
  type    = string
  default = "xlive_bot_price_table"
}

variable "XLIVE_PRICE_FILLER_CHAT_ID" {
  type    = string
  default = "777999"
}
