# CloudWatch Log groups and streams for CodeBuild projects
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/xlive-telegram-bot"
  retention_in_days = 30
}
#####################################
##  CodeBuild - Build Telegram Bot ##
#####################################

resource "aws_codebuild_source_credential" "github" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = "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"
}

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
    buildspec       = "terraform/buildspec-build.yml"
  }

  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    name                   = "zip"
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
