# ABAC (Attribute-Based Access Control)

terraform {
  required_version = ">=0.13"
}

provider "aws" {
  region = var.aws_region
}

### id-gateway account baseline security
module "badge" {
  source    = "Young-ook/passport/aws"
  name      = var.name
  tags      = var.tags
  namespace = var.namespace
}

resource "aws_iam_policy" "cost-center" {
  name   = join("-", [var.name, "cost-center"])
  policy = file("policy.json")
}

### groups
locals {
  baseline_groups = []
  bespoke_groups = [
    {
      name        = "cost-center"
      namespace   = var.namespace
      tags        = var.tags
      policy_arns = [aws_iam_policy.cost-center.arn]
    },
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
  users = [
    {
      name      = "joe@corp.com"
      namespace = var.namespace
      tags      = merge(var.tags, { CostCenter = "blue" })
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.groups["cost-center"].group.name,
      ]
    },
    {
      name      = "rick@corp.com"
      namespace = var.namespace
      tags      = merge(var.tags, { CostCenter = "yellow" })
      features  = { login = true }
      groups = [
        module.badge.baseline.groups["badge"].name,
        module.groups["cost-center"].group.name,
      ]
    }
  ]
}

module "users" {
  for_each   = { for user in local.users : user.name => user }
  depends_on = [module.badge]
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = lookup(each.value, "name")
  namespace  = lookup(each.value, "namespace")
  tags       = lookup(each.value, "tags")
  features   = lookup(each.value, "features")
  groups     = lookup(each.value, "groups")
}


# default vpc
module "vpc" {
  source = "Young-ook/vpc/aws"
  name   = var.name
  tags   = var.tags
}

# ec2
module "ec2" {
  source  = "Young-ook/ssm/aws"
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
