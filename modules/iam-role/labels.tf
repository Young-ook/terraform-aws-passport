### frigga name
module "frigga" {
  source  = "Young-ook/spinnaker/aws//modules/frigga"
  version = "2.3.5"
  name    = var.name == null || var.name == "" ? "role" : var.name
  petname = var.name == null || var.name == "" ? true : false
}

locals {
  name      = module.frigga.name
  namespace = var.namespace == null ? "/" : join("/", ["", var.namespace, ""])
  default-tags = merge(
    { "terraform.io" = "managed" },
    { "Name" = local.name },
  )
}
