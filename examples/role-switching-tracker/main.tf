# user activity tracker with AWS Lambda

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

## event pattern
## there are the definitions of roles in the badge.tf
## if you want to see who can switch to a role, please refer to the file for details.
locals {
  event_rules = [
    {
      name = "rescue-role-filter"
      event_pattern = jsonencode({
        detail = {
          eventName = ["AssumeRole"],
          requestParameters = {
            roleArn = [module.role["rescue"].role.arn]
        } },
        detail-type = ["AWS API Call via CloudTrail"],
        source      = ["aws.sts"]
      })
    },
    {
      name = "developer-role-filter"
      event_pattern = jsonencode({
        detail = {
          eventName = ["AssumeRole"],
          requestParameters = {
            roleArn = [module.role["developer"].role.arn]
        } },
        detail-type = ["AWS API Call via CloudTrail"],
        source      = ["aws.sts"]
      })
    },
  ]
}

# zip arhive
data "archive_file" "lambda_zip_file" {
  output_path = join("/", [path.module, "lambda_handler.zip"])
  source_dir  = join("/", [path.module, "watchapp"])
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

module "uat" {
  depends_on = [data.archive_file.lambda_zip_file]
  source     = "../../modules/aws-events"
  name       = var.name
  tags       = var.tags
  rules      = local.event_rules
  lambda = {
    package = "lambda_handler.zip"
    handler = "lambda_handler.lambda_handler"
    environment_variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
      SLACK_CHANNEL     = var.slack_channel
    }
  }
}
