resource "random_pet" "name" {
  count     = var.enabled ? 1 : 0
  length    = 3
  prefix    = "iam"
  separator = "-"
}

locals {
  name      = var.name == null ? (var.enabled ? random_pet.name.0.id : "") : var.name
  namespace = var.namespace == null ? "/" : join("/", ["", var.namespace, ""])
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
