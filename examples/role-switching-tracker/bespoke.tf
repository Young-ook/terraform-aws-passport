# bespoke accout

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
