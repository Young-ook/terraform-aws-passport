# user activity tracker with AWS Lambda

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

# event pattern
locals {
  pattern_event = {
    pattern = {
      rule_config = {
        event_pattern = jsonencode(
          {
            detail = {
              eventName = ["AssumeRole"],
              requestParameters = {
                roleArn = [module.bespoke["rescue"].role.arn]
              }
            },
            detail-type = ["AWS API Call via CloudTrail"],
            source      = ["aws.sts"]
          }
        )
      }
    }
  }
}

# zip arhive
data "archive_file" "lambda_zip_file" {
  output_path = "${path.module}/lambda_handler.zip"
  source_dir  = "${path.module}/src/"
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

module "uat" {
  depends_on   = [data.archive_file.lambda_zip_file]
  source       = "../../modules/uat"
  name         = var.name
  tags         = var.tags
  event_config = local.pattern_event
  lambda_config = {
    package = "lambda_handler.zip"
    handler = "lambda_handler.lambda_handler"
  }
}
