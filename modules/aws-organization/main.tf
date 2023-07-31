### organization
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = { for ou in var.organization_units : ou.name => ou }
  name      = join("-", [local.name, each.key])
  parent_id = lookup(each.value, "parent_id")
}
