# output variables

locals {
  baseline_groups = zipmap(
    ["audit", "badge", "security"],
    [
      module.audit-group.group,
      module.badge-group.group,
      module.security-group.group,
    ]
  )
  baseline_roles = zipmap(
    ["audit", "security"],
    [
      module.role["audit"],
      module.role["security"],
    ]
  )
}

output "baseline" {
  description = "The baseline of passport badge account"
  value = {
    groups = local.baseline_groups,
    roles  = local.baseline_roles,
  }
}
