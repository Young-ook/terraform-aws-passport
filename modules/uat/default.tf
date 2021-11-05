# default variables

locals {
  event_config = var.event_config == null ? {} : var.event_config
}
