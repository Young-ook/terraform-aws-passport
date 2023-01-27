### Passport Blueprint

terraform {
  required_version = ">=0.13"
}

provider "aws" {
  region = var.aws_region
}

### id-gateway account baseline security
module "badge" {
  source    = "Young-ook/passport/aws"
  version   = "0.0.7"
  name      = var.name
  tags      = var.tags
  namespace = var.namespace
}

### groups
locals {
  baseline_groups = []
  bespoke_groups = [
    {
      name         = "developer"
      namespace    = var.namespace
      tags         = var.tags
      target_roles = [module.bespoke["developer"].role.arn]
    },
    {
      name         = "rescue"
      namespace    = var.namespace
      tags         = var.tags
      target_roles = [module.bespoke["rescue"].role.arn]
    }
  ]
}

module "groups" {
  for_each     = { for group in concat(local.bespoke_groups, local.baseline_groups) : group.name => group }
  depends_on   = [module.badge]
  source       = "Young-ook/passport/aws//modules/iam-group"
  name         = lookup(each.value, "name")
  namespace    = lookup(each.value, "namespace")
  tags         = lookup(each.value, "tags")
  policy_arns  = lookup(each.value, "policy_arns", [])
  target_roles = lookup(each.value, "target_roles", [])
}

### users
locals {
  baseline_users = [
    {
      name      = "tom@corp.com"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.badge.baseline.groups["security"].name,
      ]
    },
  ]
  bespoke_users = [
    {
      name      = "joe@corp.com"
      namespace = var.namespace
      tags      = merge(var.tags, { CostCenter = "blue" })
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.groups["developer"].group.name,
        module.groups["rescue"].group.name,
      ]
    },
    {
      name      = "rick@corp.com"
      namespace = var.namespace
      tags      = merge(var.tags, { CostCenter = "yellow" })
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.groups["developer"].group.name,
        module.groups["rescue"].group.name,
      ]
    },
  ]
}

module "user" {
  for_each   = { for user in concat(local.bespoke_users, local.baseline_users) : user.name => user }
  depends_on = [module.badge]
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = lookup(each.value, "name")
  namespace  = lookup(each.value, "namespace")
  tags       = lookup(each.value, "tags")
  features   = lookup(each.value, "features")
  groups     = lookup(each.value, "groups")
}

### A spoke account is an AWS account for application or purpose built account.
### Basically, all IAM users (read only IAM users) in the badge account
### should assume role from spoke account via cross-account Role Switching.
locals {
  bespoke_roles = [
    {
      name      = "rescue"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
        aws_iam_policy.cost-center.arn,
      ]
    },
    {
      name      = "developer"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
        aws_iam_policy.cost-center.arn,
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

### security/policy
resource "aws_iam_policy" "cost-center" {
  name   = join("-", [var.name, "cost-center"])
  policy = file("policy.json")
}

### network/vpc
module "vpc" {
  source  = "Young-ook/vpc/aws"
  version = "1.0.3"
  name    = var.name
  tags    = var.tags
}

# ec2
module "ec2" {
  source  = "Young-ook/ssm/aws"
  version = "1.0.5"
  name    = var.name
  tags    = var.tags
  subnets = values(module.vpc.subnets["public"])
  node_groups = [
    {
      name          = "blue"
      desired_size  = 1
      instance_type = "t3.large"
      tags          = { CostCenter = "blue" }
    },
    {
      name          = "yellow"
      desired_size  = 1
      instance_type = "t3.large"
      tags          = { CostCenter = "yellow" }
    },
  ]
}

### security/tracker
locals {
  event_rules = [
    {
      name = "rescue-role-filter"
      event_pattern = jsonencode({
        detail = {
          eventName = ["AssumeRole"],
          requestParameters = {
            roleArn = [module.bespoke["rescue"].role.arn]
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
            roleArn = [module.bespoke["developer"].role.arn]
        } },
        detail-type = ["AWS API Call via CloudTrail"],
        source      = ["aws.sts"]
      })
    },
  ]
}

data "archive_file" "lambda_zip_file" {
  output_path = join("/", [path.module, "lambda_handler.zip"])
  source_dir  = join("/", [path.module, "watchapp"])
  excludes    = ["__init__.py", "*.pyc"]
  type        = "zip"
}

module "uat" {
  depends_on = [data.archive_file.lambda_zip_file]
  source     = "Young-ook/eventbridge/aws//modules/aws-events"
  version    = "0.0.8"
  name       = var.name
  tags       = var.tags
  rules      = local.event_rules
  lambda = {
    package = "lambda_handler.zip"
    handler = "lambda_handler.lambda_handler"
    environment_variables = {
      SLACK_WEBHOOK_URL = lookup(var.slack, "webhook_url", "")
      SLACK_CHANNEL     = lookup(var.slack, "channel", "")
    }
  }
}
