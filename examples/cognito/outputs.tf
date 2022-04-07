output "cognito" {
  description = "Attributes of cognito IdP"
  value       = module.idp
}

output "pinpoint" {
  description = "Attributes of marketing application"
  value       = aws_pinpoint_app.marketing
}
