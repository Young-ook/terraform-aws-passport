# RBAC (Role-Based Access Control)

terraform {
  required_version = ">=0.13"
}

module "badge" {
  source    = "../../"
  name      = var.name
  tags      = var.tags
  namespace = var.namespace
}

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

module "group" {
  for_each     = { for group in concat(local.bespoke_groups, local.baseline_groups) : group.name => group }
  depends_on   = [module.badge]
  source       = "Young-ook/passport/aws//modules/iam-group"
  name         = lookup(each.value, "name")
  namespace    = lookup(each.value, "namespace")
  tags         = lookup(each.value, "tags")
  policy_arns  = lookup(each.value, "policy_arns", [])
  target_roles = lookup(each.value, "target_roles", [])
}

locals {
  baseline_users = [
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
  source        = "Young-ook/passport/aws//modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policy_arns   = lookup(each.value, "policy_arns", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}
