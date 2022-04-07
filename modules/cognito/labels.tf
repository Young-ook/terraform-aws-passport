resource "random_string" "uid" {
  length  = 12
  upper   = false
  lower   = true
  number  = false
  special = false
}

locals {
  service = "cognito"
  uid     = join("-", [local.service, random_string.uid.result])
  name    = var.name == null || var.name == "" ? local.uid : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}

resource "random_string" "extid" {
  length  = 16
  upper   = true
  lower   = false
  number  = false
  special = false
}
