resource "random_pet" "name" {
  length    = 3
  prefix    = "iam"
  separator = "-"
}

locals {
  name      = var.name == null ? random_pet.name.id : var.name
  namespace = var.namespace == null ? "/" : join("/", ["", var.namespace, ""])
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
