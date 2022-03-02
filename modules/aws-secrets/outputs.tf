# output variables

output "secret" {
  description = "The attributes of secret manager"
  value       = aws_secretsmanager_secret.secret
}

output "policy_arns" {
  description = "A map of IAM polices to allow access this secret. If you want to make an IAM role or instance-profile has permissions to retrieve this secret, please attach the `poliy_arn` of this output on your side."
  value       = zipmap(["read"], [aws_iam_policy.read.arn])
}
