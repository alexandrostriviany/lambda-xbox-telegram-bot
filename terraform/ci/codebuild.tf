# CloudWatch Log groups and streams for CodeBuild projects
resource "aws_cloudwatch_log_group" "codebuild" {
  name              = "/aws/codebuild/xlive-telegram-bot"
  retention_in_days = 30
}

//resource "aws_codebuild_source_credential" "github" {
//  auth_type   = "PERSONAL_ACCESS_TOKEN"
//  server_type = "GITHUB"
//  token       = var.git_token
//}

########################################
##  CodeBuild - Build xlive-price-bot ##
########################################

resource "aws_codebuild_project" "telegram_bot_build" {
  name          = "xlive-price-bot"
  description   = "Build xlive-price-bot Telegram Bot Project"
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
    buildspec = "terraform/ci/specs/buildspec-build.yml"
  }

  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"]
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "xlive-price-bot-build"
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
    type      = "CODEPIPELINE"
    buildspec = "terraform/ci/specs/buildspec-xlive-price-filler-build.yml"
  }

  cache {
    type  = "LOCAL"
    modes = [
      "LOCAL_DOCKER_LAYER_CACHE"]
  }
  artifacts {
    type = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = aws_cloudwatch_log_group.codebuild.name
      stream_name = "xlive-price-filler-build"
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
    type  = "LOCAL"
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
