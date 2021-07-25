# Passport

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

module "group" {
  for_each     = { for group in concat(local.bespoke_groups, local.groups) : group.name => group }
  providers    = { aws = aws.badge }
  depends_on   = [module.badge]
  source       = "Young-ook/passport/aws//modules/iam-group"
  name         = lookup(each.value, "name")
  namespace    = lookup(each.value, "namespace")
  tags         = lookup(each.value, "tags")
  policies     = lookup(each.value, "policies", [])
  target_roles = lookup(each.value, "target_roles", [])
}

locals {
  groups = []
}

module "user" {
  for_each   = { for user in concat(local.bespoke_users, local.users) : user.name => user }
  providers  = { aws = aws.badge }
  depends_on = [module.badge]
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = lookup(each.value, "name")
  namespace  = lookup(each.value, "namespace")
  tags       = lookup(each.value, "tags")
  features   = lookup(each.value, "features")
  groups     = lookup(each.value, "groups")
}

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
  ]
}