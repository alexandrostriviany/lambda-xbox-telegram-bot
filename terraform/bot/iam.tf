resource "aws_iam_role" "lambda_exec" {
  name = var.iam-role-name
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Action : "sts:AssumeRole",
          Principal : {
            "Service" : "lambda.amazonaws.com"
          },
          Effect : "Allow",
          Sid : ""
        }
      ]
  })
}

resource "aws_iam_role_policy" "role_policy" {
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          Action : [
            "cloudwatch:*",
            "logs:*",
            "dynamodb:*",
            "lambda:*",
          ],
          Effect : "Allow",
          Resource : "*"
        }
      ]
    }
  )
  role = aws_iam_role.lambda_exec.id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xlive-price-filler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.xlive-price-cron-trigger.arn
}