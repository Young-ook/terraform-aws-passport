# output variables

locals {
  predefined_groups = zipmap(
    ["badge", "security", "audit"],
    [
      module.badge-group.group,
      module.security-group.group,
      module.audit-group.group,
    ]
  )
}

output "account" {
  description = "The attributes of passport badge account"
  value = {
    predefined_groups = local.predefined_groups,
    predefined_roles  = module.role,
  }
}
