locals {
  version = "5.7.mysql_aurora.2.07.1"
}

output "aurora_version" {
  value = substr(local.version, -6, -1)
}
