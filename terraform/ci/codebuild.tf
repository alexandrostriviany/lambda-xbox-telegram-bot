# CloudWatch Log groups and streams for CodeBuild projects
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/xlive-telegram-bot"
  retention_in_days = 30
}

########################################
##  CodeBuild - Build xlive-price-bot ##
########################################

resource "aws_codebuild_project" "telegram_bot_build" {
  name          = var.lambda_bot_name
  description   = "Build ${var.lambda_bot_name} Telegram Bot Project"
  build_timeout = 20
  service_role  = aws_iam_role.code_build_role.arn

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/ci/specs/buildspec-xlive-price-bot-build.yml"
  }

  cache {
    type = "LOCAL"
    modes = [
    "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "${var.lambda_bot_name}-build"
    }
  }
}

###########################################
##  CodeBuild - Build xlive-price-filler ##
###########################################

resource "aws_codebuild_project" "xlive_price_filler_build" {
  name          = var.lambda_filler_name
  description   = "Build ${var.lambda_filler_name} Lambda project"
  build_timeout = 20
  service_role  = aws_iam_role.code_build_role.arn

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/ci/specs/buildspec-xlive-price-filler-build.yml"
  }

  cache {
    type = "LOCAL"
    modes = [
    "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "${var.lambda_filler_name}-build"
    }
  }
}

###########################################
##  CodeBuild - Deploy application       ##
###########################################

resource "aws_codebuild_project" "deploy" {
  name          = "xlive-deploy"
  description   = "Deploy xlive-price-application"
  build_timeout = 20
  service_role  = aws_iam_role.code_build_role.arn

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/ci/specs/buildspec-application-deploy.yml"
  }

  cache {
    type = "LOCAL"
    modes = [
    "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "xlive-deploy"
    }
  }
}

###########################################
##  CodeBuild - Set webhook              ##
###########################################

resource "aws_codebuild_project" "set_webhook" {
  name          = "set-webhook"
  description   = "Set Telegram Bot webhook to ApiGW"
  build_timeout = 20
  service_role  = aws_iam_role.code_build_role.arn

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:3.0"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "terraform/ci/specs/buildspec-set-webhook.yml"
  }

  cache {
    type = "LOCAL"
    modes = [
    "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "xlive-deploy"
    }
  }
}


