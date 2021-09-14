resource "aws_codepipeline" "xlive_telegram_bot" {
  name     = "xlive-telegram-bot"
  role_arn = aws_iam_role.code_pipeline.arn

  artifact_store {
    type     = "S3"
    location = var.source_s3_store
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = [
        "Source"]

      configuration = {
        OAuthToken = data.aws_ssm_parameter.ami.value
        Owner      = var.github_owner
        Repo       = "lambda-xbox-telegram-bot"
        Branch     = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "xlive-price-bot"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [
        "Source"]
      output_artifacts = [
        "XlivePriceBotZip"]
      configuration    = {
        ProjectName = aws_codebuild_project.telegram_bot_build.name
      }
    }

    action {
      name             = "xlive-price-filler"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = [
        "Source"]
      output_artifacts = [
        "XlivePriceFillerZip"]
      configuration    = {
        ProjectName = aws_codebuild_project.xlive_price_filler_build.name
      }
    }

  }

  stage {
    name = "DeployToS3"

    action {
      name            = "PriceFillerZip"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = [
        "XlivePriceFillerZip"]

      configuration = {
        BucketName = aws_s3_bucket.test_lambda_store_s3_bucket.bucket
        Extract    = "true"
      }
    }
    action {
      name            = "TelegramBotZip"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      version         = "1"
      input_artifacts = [
        "XlivePriceBotZip"]

      configuration = {
        BucketName = aws_s3_bucket.test_lambda_store_s3_bucket.bucket
        Extract    = "true"
      }
    }
  }

  stage {
    name = "DeployApplication"

    action {
      name            = "Publish"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 1
      input_artifacts = [
        "Source"]

      configuration = {
        ProjectName = aws_codebuild_project.deploy.name
      }
    }

    action {
      name      = "ManualApproval"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 2
    }

    action {
      name            = "SetTelegramWebhook"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      run_order       = 3
      input_artifacts = [
        "Source"]

      configuration = {
        ProjectName = aws_codebuild_project.set_webhook.name
      }
    }
  }
}
