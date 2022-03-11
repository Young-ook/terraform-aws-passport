# output variables

output "rules" {
  description = "The attributes of eventbridge rules"
  value       = module.event
}

output "lambda" {
  description = "The attributes of event hnadler"
  value       = module.lambda
}
