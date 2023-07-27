### organization
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"
}

resource "aws_organizations_organizational_unit" "ou" {
  name      = join("-", [local.name, "ou"])
  parent_id = aws_organizations_organization.org.roots[0].id
}
