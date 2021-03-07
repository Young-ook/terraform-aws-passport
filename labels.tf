locals {
  namespace = var.namespace == null ? "/" : join("/", ["", var.namespace, ""])
}
