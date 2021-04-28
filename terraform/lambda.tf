provider "aws" {
  profile = "personal"
  region  = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "xlive-price-filler" {
  filename      = "../xlive-price-filler/build/distributions/xlive-price-filler-1.0-SNAPSHOT.zip"
  function_name = var.lambda_filler_name
  handler       = "com.lambdatelegram.App"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "java8"
  timeout       = 50
  memory_size   = 512
  environment {
    variables = {
      BOT_URL = var.BOT_URL
      XLIVE_PRICE_FILLER_CHAT_ID = var.XLIVE_PRICE_FILLER_CHAT_ID
      PRICE_TABLE = var.PRICE_TABLE
      REGION = var.region
    }
  }
}

resource "aws_lambda_function" "xlive-price-bot-lambda" {
  filename      = "../xlive-price-bot/build/distributions/xlive-price-bot-1.0-SNAPSHOT.zip"
  function_name = var.lambda_bot_name
  handler       = "com.lambdatelegram.xlivepricebot.App"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "java8"
  timeout       = 30
  memory_size   = 512
  environment {
    variables = {
      bot_token = var.BOT_TOKEN
      bot_username = var.BOT_USERNAME
      PRICE_TABLE = var.PRICE_TABLE
      REGION = var.region
      XLIVE_PRICE_FILLER_CHAT_ID = var.XLIVE_PRICE_FILLER_CHAT_ID
    }
  }
}

resource "aws_lambda_permission" "api-gw-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xlive-price-bot-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.xlive-price-bot-api.id}/*/${aws_api_gateway_method.gw-method.http_method}${aws_api_gateway_resource.resource.path}"
}