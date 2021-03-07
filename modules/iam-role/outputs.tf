# output variables

output "role" {
  description = "The attributes of generated role"
  value       = var.enabled ? aws_iam_role.role.0 : null
}
