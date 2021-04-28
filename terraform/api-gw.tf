resource "aws_api_gateway_rest_api" "xlive-price-bot-api" {
  name        = "xlive-price-bot-api"
  description = "Xbox Live Gold/Pass/Ultimate bot API GW"
  endpoint_configuration {
    types = [
      "REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.xlive-price-bot-api.id
  parent_id   = aws_api_gateway_rest_api.xlive-price-bot-api.root_resource_id
  path_part   = var.BOT_PATH
}

resource "aws_api_gateway_method" "gw-method" {
  rest_api_id   = aws_api_gateway_rest_api.xlive-price-bot-api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api-lambda-integration" {
  rest_api_id = aws_api_gateway_rest_api.xlive-price-bot-api.id
  resource_id = aws_api_gateway_method.gw-method.resource_id
  http_method = aws_api_gateway_method.gw-method.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.xlive-price-bot-lambda.invoke_arn
  request_templates       = {
    "application/xml" = <<EOF
{
   "body" : $input.json('$')
}
EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.xlive-price-bot-api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.gw-method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.xlive-price-bot-api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.gw-method.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
  depends_on  = [
    aws_api_gateway_integration.api-lambda-integration
  ]
}

resource "aws_api_gateway_deployment" "bot-api-deployment" {
  depends_on = [
    aws_api_gateway_integration.api-lambda-integration,
    aws_api_gateway_integration_response.MyDemoIntegrationResponse
  ]

  rest_api_id = aws_api_gateway_rest_api.xlive-price-bot-api.id
  stage_name  = "prod"
}

output "base_url" {
  value = "${aws_api_gateway_deployment.bot-api-deployment.invoke_url}/${aws_api_gateway_resource.resource.path_part}"
}