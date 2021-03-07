locals {
  roles = [
    {
      name      = "rescue"
      namespace = var.namespace
      tags      = var.tags
      policies = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
    {
      name      = "data-scientist"
      namespace = var.namespace
      tags      = var.tags
      policies = [
        "arn:aws:iam::aws:policy/job-function/DataScientist"
      ]
    }
  ]
}

module "role" {
  for_each      = { for role in local.roles : role.name => role }
  source        = "../../../../modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policies      = lookup(each.value, "policies", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}
