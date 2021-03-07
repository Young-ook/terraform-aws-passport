# output variables

output "badge_account" {
  description = "The attributes of badge(ID) gateway account"
  value       = module.badge.account
}

#output "password" {
#  description = "The automatically generated password for initial access of the users"
#  value = zipmap(
#    ["security-officer-user", "data-scientist-user", ],
#    [module.security-officer-user.password, module.data-scientist-user.password, ]
#  )
#}
