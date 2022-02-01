resource "random_pet" "name" {
  length    = 3
  prefix    = "awsconfig"
  separator = "-"
}

locals {
  name = var.name == null || var.name == "" ? random_pet.name.id : var.name
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
