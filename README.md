# XLIVE PRICE TELEGRAM BOT ON AWS LAMBDA
##Bot
- Telegram bot
- Implemented in Java with [Gradle]
- [gradle-aws-plugin] is used to update lambdas
- [TelegramBots] library is used to parse updates and to send messages
- [AWS Toolkit](https://plugins.jetbrains.com/plugin/11349-aws-toolkit) IDEA plugin to debug Lambda
##Infra
- Host on [AWS]
- Using [API-GW -> Lambda -> DynamoDb] approach
- Webhook on [AWS-API-GW]
- Manage infrastructure with [Terraform]

## About
Telegram bot that helps to keep track of changes in XBOX subscription prices and promotions.

## Usage
Terraform scripts allow you to easily create all infrastructure for bot and Gradle plugin helps build and deploy the java lambda function.
In order to use it, you should install [Terraform](https://www.terraform.io/downloads.html)
Also you have to have an Amazon AWS account. 
Then you need to [create an access key](http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html)
for your account and to [configure the AWS CLI](http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html)
on your dev machine. This will give you the "profile name" that you need to specify in your gradle script:
```
aws {
    profileName = 'default'
}
```
Then you can configure your future (or existing) lambda parameters:
```
def lambda_name_test = "BotTest"
def lambda_name_production = "BotProd"
```
**Note!** if you have several accounts, specify the required

### Create Bot in Telegram
- Talk to [BotFather](https://t.me/botfather) and follow a few simple steps. After you did it a bot will receive bot username and authorization token.
### Packege your code to ZIP
- Go to `./lambda-xbox-telegram-bot/xlive-price-bot/build.gradle` and run `buildZip`
- Go to `./lambda-xbox-telegram-bot/xlive-price-filler/build.gradle` and run `buildZip`

### Create AWS infrastructure
- Go to terraform variables file `./lambda-xbox-telegram-bot/terraform/vars.tf`
- Сhange the `region` to the one you are using.
- Open `./lambda-xbox-telegram-bot/terraform` in the terminal and init terraform project
```
terraform init
```
- Set bot credentials and api-path to the ENV variables 
```
export TF_VAR_BOT_TOKEN="example-token"
export TF_VAR_BOT_USERNAME="telegramBotExample"
export TF_VAR_BOT_PATH="telegram"
```
**Note!** your can skip it and add env variables manually for lambdas in AWS console
- Run terraform (for now leave BOT_URL parameter empty)
```
terraform apply
```
- In the end you should see `base_url` in the output
```
Apply complete! Resources: 16 added, 0 changed, 0 destroyed.

Outputs:

base_url = "https://example.amazonaws.com/prod/telegram"
```
- Run it again and set base_url output to BOT_URL
```
var.BOT_URL
  Enter a value: https://example.amazonaws.com/prod/telegram
```
- Well done. All infrastructure is setted up!

### Set webhook

When you have your API staged, you need to register URL addresses in the Telegram, so they will know
where to send all the updates for your bot. You can do it by sending a POST request like this:
```
curl -X POST "https://api.telegram.org/bot${token}/setWebhook?url=${base_url}"
```

Insert the token of your bot and the corresponding URL address and you good to go.
After successull request like that - your lambda should start to receive all the messages sent to your bot.

### Update lambda

After you already got an existing lambda and you just want to update
its code, call:
```
gradle deploy
```
or
```
gradle deploy_production
```
In order to build an uberjar and to upload it to either test or production
lambda respectively.

**NOTE** variables in build.gradle should be the same as in var.tf
- xlive-price-bot/build.gradle#lambda_name_test = var.tf#"lambda_bot_name"
- xlive-price-filler/build.gradle#lambda_name_test = var.tf#"lambda_filler_name"
- also region and profile

## Fire up

Note that when you call your bot first time after an update, or after a long time
pause - it needs a time to fire up your lambda environment. Amazon actually starts up
a lambda only when it's called and kills it when it not called for some time.

So give it a few seconds.

## Logs

Do not forget that a LogGroup with a name `/aws/lambda/${LambdaName}` is automatically created for each lambda.
You can find logs in [CloudWatch console](https://console.aws.amazon.com/cloudwatch/home#logs:)

[API-GW -> Lambda -> DynamoDb]:https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-dynamo-db.html
[AWS]: https://aws.amazon.com/
[AWS-API-GW]: https://aws.amazon.com/api-gateway/
[Gradle]: https://gradle.org/
[gradle-aws-plugin]: https://github.com/classmethod/gradle-aws-plugin
[TelegramBots]: https://github.com/rubenlagus/TelegramBots
[Terraform]: https://www.terraform.io/
