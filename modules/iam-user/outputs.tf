# output variables

output "user" {
  description = "The attributes of generated user"
  value       = var.enabled ? aws_iam_user.user.0 : null
}

output "password" {
  description = "The initial password of the user. All new users must change this initial password after first sign-in on AWS console"
  value       = local.login_enabled && var.enabled ? random_password.password.0.result : null
  sensitive   = true
}
