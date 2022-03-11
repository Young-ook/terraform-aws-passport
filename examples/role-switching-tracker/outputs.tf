# output variables

output "uat" {
  value     = module.uat
  sensitive = true
}

output "group" {
  value = module.group
}
