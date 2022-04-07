# Amazon Cognito IdP example

terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# security/idp
module "idp" {
  source = "../../modules/cognito"
  name   = var.name
  tags   = var.tags
  policy_arns = {
    authenticated   = [aws_iam_policy.put-events.arn]
    unauthenticated = [aws_iam_policy.put-events.arn]
  }
}

# analytics
resource "random_pet" "name" {
  length    = 3
  separator = "-"
}

resource "aws_pinpoint_app" "marketing" {
  name = random_pet.name.id
  tags   = var.tags
}

resource "aws_iam_policy" "put-events" {
  name = join("-", [random_pet.name.id, "put-events"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "mobileanalytics:PutEvents",
          "personalize:PutEvents",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "mobiletargeting:UpdateEndpoint",
          "mobiletargeting:PutEvents",
        ]
        Effect   = "Allow"
        Resource = [aws_pinpoint_app.marketing.arn]
      },
    ]
  })
}
