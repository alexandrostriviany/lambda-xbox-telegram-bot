resource "aws_iam_role" "lambda_exec" {
  name               = var.iam-role-name
  assume_role_policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        Action: "sts:AssumeRole",
        Principal: {
          "Service": "lambda.amazonaws.com"
        },
        Effect: "Allow",
        Sid: ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "role_policy" {
  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        Action: [
          "cloudwatch:*",
          "logs:*",
          "dynamodb:*",
          "lambda:*",
        ],
        Effect: "Allow",
        Resource: "*"
      }
    ]
  }
  )
  role   = aws_iam_role.lambda_exec.id
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.xlive-price-filler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.xlive-price-cron-trigger.arn
}

resource "aws_iam_role" "code_build_role" {
  name               = "lambda-build-role"
  description        = "CodeBuild role for lambda"
  assume_role_policy = data.aws_iam_policy_document.code_build_assume.json
}

resource "aws_iam_policy_attachment" "codebuild_policy_attachment" {
  name       = "codebuild_policy_attachment"
  roles      = [
    aws_iam_role.code_build_role.name]
  policy_arn = aws_iam_policy.codebuild_iam_policy.arn
}


data "aws_iam_policy_document" "code_build_assume" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "codebuild_iam_policy" {
  name        = "xlive-bot-lambda-policy"
  description = "Policy for test runner lambda"
  policy      = data.aws_iam_policy_document.code_build.json
}

data "aws_iam_policy_document" "code_build" {
  statement {
    sid       = "generalReadAccess"
    effect    = "Allow"
    resources = [
      "*"]
    actions   = [
      "acm:DescribeCertificate",
      "acm:GetCertificate",
      "acm:List*",
      "codebuild:*",
      "codepipeline:*",
      "iam:Get*",
      "iam:List*",
      "kms:ListAliases",
      "kms:DescribeKey",
      "logs:*",
      "tag:Get*"
    ]
  }

  statement {
    sid       = "allowIAMLambda"
    effect    = "Allow"
    resources = [
      "*"
    ]
    actions   = [
      "iam:*"]
  }
  statement {
    sid       = "allowLambda"
    effect    = "Allow"
    resources = [
      "*"
    ]
    actions   = [
      "lambda:*"]
  }
  statement {
    sid       = "allowCloudWatchEvents"
    effect    = "Allow"
    resources = [
      "*"
    ]
    actions   = [
      "events:*"]
  }
  statement {
    sid       = "allowCloudWatchLogs"
    effect    = "Allow"
    resources = [
      "*"
    ]
    actions   = [
      "logs:*"
    ]
  }
  statement {
    sid       = "allowS3Buckets"
    effect    = "Allow"
    resources = [
      "*",
    ]
    actions   = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:ListBucket"
    ]
  }
  statement {
    sid       = "allowSecretsManager"
    effect    = "Allow"
    resources = [
      "*"]
    actions   = [
      "secretsmanager:GetSecretValue"
    ]
  }
  statement {
    sid       = "allowSSMParametersStore"
    effect    = "Allow"
    resources = [
      "*"]
    actions   = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
  }
}