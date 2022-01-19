# Passport

terraform {
  required_version = ">=0.13"
}

### A spoke account is an AWS account for application or purpose built account.
### Basically, all IAM users (read only IAM users) in the badge account
### should assume role from spoke account via cross-account Role Switching.
provider "aws" {
  alias               = "application"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account]
}

locals {
  bespoke_roles = [
    {
      name      = "rescue"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
    {
      name      = "developer"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess",
      ]
    },
  ]
}

module "bespoke" {
  for_each      = { for role in local.bespoke_roles : role.name => role }
  providers     = { aws = aws.application }
  source        = "Young-ook/passport/aws//modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policy_arns   = lookup(each.value, "policy_arns", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}
