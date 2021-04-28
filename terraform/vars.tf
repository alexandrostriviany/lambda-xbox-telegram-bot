variable "region" {
  type = string
  default = "eu-central-1"
}
variable "lambda_filler_name" {
  type = string
  default = "xlive-price-filler"
}
variable "lambda_bot_name" {
  type = string
  default = "xlive-price-bot"
}
variable "iam-role-name" {
  type = string
  default = "xlive-price"
}
variable "schedule-parameter" {
  type = string
  default = "cron(15,45 5-22 * * ? *)"
}
variable "PRICE_TABLE" {
  type = string
  default = "xlive_bot_price_table"
}
variable "XLIVE_PRICE_FILLER_CHAT_ID" {
  type = string
  default = "777999"
}
variable "BOT_PATH" {
  type = string
}
variable "BOT_URL" {
  type = string
}
variable "BOT_TOKEN" {
  type = string
}
variable "BOT_USERNAME" {
  type = string
}
