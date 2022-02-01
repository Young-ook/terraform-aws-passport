# output variables

output "bespoke" {
  description = "The attribute of bespoke account"
  value       = module.bespoke
}

output "guardrails" {
  description = "Basline guardrails"
  value       = [module.rules.rules]
}
