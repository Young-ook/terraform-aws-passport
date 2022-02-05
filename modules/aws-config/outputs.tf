# output variables

output "rules" {
  description = "The attributes of config rules"
  value       = aws_config_config_rule.rules
}
