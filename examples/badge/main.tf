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

### users in id-gateway account
locals {
  users = [
    {
      name      = "security-officer@corp.com"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.badge.baseline.groups["security"].name,
      ]
    },
    {
      name      = "developer@corp.com"
      namespace = var.namespace
      tags      = var.tags
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
      ]
    }
  ]
}

module "user" {
  for_each   = { for user in local.users : user.name => user }
  providers  = { aws = aws.badge }
  depends_on = [module.badge]
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = lookup(each.value, "name")
  namespace  = lookup(each.value, "namespace")
  tags       = lookup(each.value, "tags")
  features   = lookup(each.value, "features")
  groups     = lookup(each.value, "groups")
}