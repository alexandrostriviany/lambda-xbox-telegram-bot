resource "aws_cloudwatch_event_rule" "xlive-price-cron-trigger" {
  name                = "xlive-price-cron-trigger"
  description         = "Fires every 30 minutes between 8:00 am and 22:00"
  schedule_expression = var.schedule-parameter
}

resource "aws_cloudwatch_event_target" "periodically-check" {
  rule      = aws_cloudwatch_event_rule.xlive-price-cron-trigger.name
  target_id = aws_lambda_function.xlive-price-filler.id
  arn       = aws_lambda_function.xlive-price-filler.arn
}