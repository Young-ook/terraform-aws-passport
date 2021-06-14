# Passport

terraform {
  required_version = ">=0.13"
}

### id-gateway account baseline security
provider "aws" {
  alias               = "badge"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account]
}

module "badge" {
  providers   = { aws = aws.badge }
  source      = "../../"
  name        = var.name
  tags        = var.tags
  aws_account = var.aws_account
  namespace   = var.namespace
}

### groups in id-gateway account
###
### Here is the example to show how to allow the (read-only) users in the data-scientist group
### to switch the data-scientist role over the cross account for the training job management.

locals {
  groups = [
    {
      name         = "data-scientist"
      namespace    = var.namespace
      tags         = var.tags
      target_roles = [module.analytics.roles["data-scientist"].role.arn]
    },
    {
      name         = "rescue"
      namespace    = var.namespace
      tags         = var.tags
      target_roles = [module.analytics.roles["rescue"].role.arn]
    }
  ]
}

module "group" {
  for_each     = { for group in local.groups : group.name => group }
  providers    = { aws = aws.badge }
  depends_on   = [module.badge, module.analytics]
  source       = "../../modules/iam-group"
  name         = lookup(each.value, "name")
  namespace    = lookup(each.value, "namespace")
  tags         = lookup(each.value, "tags")
  policies     = lookup(each.value, "policies", [])
  target_roles = lookup(each.value, "target_roles", [])
}

### users in id-gateway account
locals {
  users = [
    {
      name      = "security-officer"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.account.predefined_groups["badge"].name,
        module.badge.account.predefined_groups["security"].name,
      ]
    },
    {
      name      = "data-scientist"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.account.predefined_groups["badge"].name,
        module.group["data-scientist"].group.name,
      ]
    },
    {
      name      = "developer"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.account.predefined_groups["badge"].name,
        module.group["rescue"].group.name,
      ]
    }
  ]
}

module "user" {
  for_each   = { for user in local.users : user.name => user }
  providers  = { aws = aws.badge }
  depends_on = [module.badge, module.analytics]
  source     = "../../modules/iam-user"
  name       = lookup(each.value, "name")
  namespace  = lookup(each.value, "namespace")
  tags       = lookup(each.value, "tags")
  features   = lookup(each.value, "features")
  groups     = lookup(each.value, "groups")
}