### aws config rules
resource "aws_config_config_rule" "rules" {
  for_each                    = { for rule in local.default_config_rules : rule.name => rule }
  name                        = each.key
  tags                        = merge(local.default-tags, var.tags)
  description                 = lookup(each.value, "description", null)
  maximum_execution_frequency = lookup(each.value, "maximum_execution_frequency", null)
  dynamic "source" {
    for_each = { for k, v in coalescelist([lookup(each.value, "source", [])]) : k => v }
    content {
      owner             = lookup(source.value, "owner")
      source_identifier = lookup(source.value, "source_identifier")
    }
  }
}
