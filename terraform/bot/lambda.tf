data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "xlive-price-filler" {

  s3_bucket = var.artifacts_s3_store
  s3_key    = "lambda/xlive-price-filler.zip"

  function_name = var.lambda_filler_name
  handler       = "com.lambdatelegram.App"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "java8"
  timeout       = 50
  memory_size   = 512
  environment {
    variables = {
      BOT_URL                    = "${aws_api_gateway_deployment.bot-api-deployment.invoke_url}/${aws_api_gateway_resource.resource.path_part}"
      XLIVE_PRICE_FILLER_CHAT_ID = var.XLIVE_PRICE_FILLER_CHAT_ID
      PRICE_TABLE                = var.PRICE_TABLE
      REGION                     = var.region
    }
  }
}

resource "aws_lambda_function" "xlive-price-bot-lambda" {


  s3_bucket = var.artifacts_s3_store
  s3_key    = "lambda/xlive-price-bot.zip"

  function_name = var.lambda_bot_name
  handler       = "com.lambdatelegram.xlivepricebot.App"
  role          = aws_iam_role.lambda_exec.arn
  runtime       = "java8"
  timeout       = 30
  memory_size   = 512
  environment {
    variables = {
      bot_token                  = var.BOT_TOKEN
      bot_username               = var.BOT_USERNAME
      PRICE_TABLE                = var.PRICE_TABLE
      REGION                     = var.region
      XLIVE_PRICE_FILLER_CHAT_ID = var.XLIVE_PRICE_FILLER_CHAT_ID
    }
  }
}

resource "aws_lambda_permission" "api-gw-permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xlive-price-bot-lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.xlive-price-bot-api.id}/*/${aws_api_gateway_method.gw-method.http_method}${aws_api_gateway_resource.resource.path}"
}