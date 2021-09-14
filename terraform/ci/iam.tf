resource "aws_iam_role" "code_build_role" {
  name               = "xlive-bot-lambda-build-role"
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

##########pipeline##############

resource "aws_iam_role" "code_pipeline" {
  name               = "xlive-telegram-bot-code-pipeline-role"
  description        = "CodePipeline role for xlive-telegram-bot"
  assume_role_policy = data.aws_iam_policy_document.code_pipeline_assume.json
}

resource "aws_iam_policy" "code_pipeline" {
  name        = "xlive-telegram-bot-code-pipeline-policy"
  path        = "/service-role/"
  description = "CodePipeline policy for xlive-telegram-bot"
  policy      = data.aws_iam_policy_document.code_pipeline.json
}

resource "aws_iam_policy_attachment" "code_pipeline" {
  name       = "xlive-telegram-bot-pipeline-policy-attachment"
  roles      = [
    aws_iam_role.code_pipeline.name]
  policy_arn = aws_iam_policy.code_pipeline.arn
}

data "aws_iam_policy_document" "code_pipeline_assume" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "codepipeline.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "code_pipeline" {
  statement {
    sid    = "allowS3ArtifactBuckets"
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]
  }

  statement {
    sid    = "allowCodeBuild"
    effect = "Allow"

    resources = [
      "*"
    ]

    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]
  }
}