# output variables

output "user" {
  description = "The attributes of generated user"
  value       = aws_iam_user.user
}

output "password" {
  description = "The initial password of the user. All new users must change this initial password after first sign-in on AWS console"
  value       = local.login_enabled ? random_password.password.result : null
  sensitive   = true
}
