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
      policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
    {
      name      = "developer"
      namespace = var.namespace
      tags      = var.tags
      policies = [
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
  policies      = lookup(each.value, "policies", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}

locals {
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

locals {
  bespoke_users = [
    {
      name      = "developer@corp.com"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
      ]
    },
  ]
}