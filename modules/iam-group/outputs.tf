# output variables

output "group" {
  description = "The attributes of generated group"
  value       = var.enabled ? aws_iam_group.group.0 : null
}
