# Baseline

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account]
}

### A spoke account is an AWS account for application or purpose built account.
locals {
  bespoke_roles = [
    {
      name      = "security-guard"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
  ]
}

module "bespoke" {
  for_each      = { for role in local.bespoke_roles : role.name => role }
  source        = "Young-ook/passport/aws//modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policy_arns   = lookup(each.value, "policy_arns", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}

### baseline rules
resource "aws_ssm_document" "cwagent" {
  name            = "Install-CloudWatch-Agent"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/cwagent.yaml")
}

resource "aws_ssm_association" "cwagent" {
  name             = aws_ssm_document.cwagent.name
  association_name = "install-cloudwatch-agent"
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

resource "aws_ssm_association" "patch-baseline" {
  name             = "AWS-RunPatchBaseline"
  association_name = "weekly-patch-baseline"
  parameters = {
    Operation = "Install"
  }
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

resource "random_pet" "ruleslog" {
  length    = 3
  separator = "-"
}

module "ruleslog" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  name          = random_pet.ruleslog.id
  tags          = var.tags
  force_destroy = true
}

module "rules" {
  source = "../../modules/aws-config"
  name   = var.name
  tags   = var.tags

  #  check_required_tags          = true
  #  required_tags_resource_types = ["S3::Bucket"]
  #  required_tags = {
  #    tag1Key   = "Automation"
  #    tag1Value = "Terraform"
  #    tag2Key   = "Environment"
  #    tag3Value = "Terratest"
  #  }

  log_config = {
    s3 = {
      bucket = module.ruleslog.bucket.id
      prefix = "awsconfig/logs"
    }
  }
}

#resource "aws_sns_topic" "config" {
#  name = var.name
#}

#output "policy" {
#  value = jsonencode({
#    Statement = [{
#      Effect = "Allow"
#      Principal = {
#        Type       = "AWS"
#        Identifier = [module.rules.rules.*.arn]
#      }
#      Action   = ["SNS:Publish"]
#      Resource = [aws_sns_topic.config.arn]
#    }]
#  })
#}

#resource "aws_sns_topic_policy" "config" {
#  arn = aws_sns_topic.config.arn
#  policy = jsonencode({
#    Statement = [{
#      Effect = "Allow"
#      Principal = {
#        Type       = "AWS"
#        Identifier = [module.rules.rules.arn]
#      }
#      Action   = ["SNS:Publish"]
#      Resource = [aws_sns_topic.config.arn]
#    }]
#  })
#}
