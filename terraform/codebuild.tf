# CloudWatch Log groups and streams for CodeBuild projects
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/xlive-telegram-bot"
  retention_in_days = 30
}

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.git_token
}

########################################
##  CodeBuild - Build xlive-price-bot ##
########################################

resource "aws_codebuild_project" "telegram_bot_build" {
  name          = "telegram-bot"
  description   = "Build Telegram Bot Project"
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
    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.github.arn
    }
    type            = "GITHUB"
    location        = "https://github.com/alexandrostriviany/lambda-xbox-telegram-bot.git"
    git_clone_depth = 1
    buildspec       = "terraform/specs/buildspec-build.yml"
  }

  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    name                   = "xlive-price-bot.zip"
    type                   = "S3"
    encryption_disabled    = "true"
    path                   = "lambda/"
    location               = var.artifacts_s3_store
    packaging              = "ZIP"
    override_artifact_name = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "java-client-build"
    }
  }
}

###########################################
##  CodeBuild - Build xlive-price-filler ##
###########################################

resource "aws_codebuild_project" "xlive_price_filler_build" {
  name          = "xlive-price-filler"
  description   = "Build xlive-price-filler"
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
    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.github.arn
    }
    type            = "GITHUB"
    location        = "https://github.com/alexandrostriviany/lambda-xbox-telegram-bot.git"
    git_clone_depth = 1
    buildspec       = "terraform/specs/buildspec-xlive-price-filler-build.yml"
  }

  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    name                   = "xlive-price-filler.zip"
    type                   = "S3"
    encryption_disabled    = "true"
    path                   = "lambda/"
    location               = var.artifacts_s3_store
    packaging              = "ZIP"
    override_artifact_name = true
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "java-client-build"
    }
  }
}

