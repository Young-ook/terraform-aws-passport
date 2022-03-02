# output variables

output "role" {
  description = "The attributes of generated role"
  value       = aws_iam_role.role
}
