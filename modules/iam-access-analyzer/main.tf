### security/audit
resource "aws_accessanalyzer_analyzer" "audit" {
  analyzer_name = local.name
  tags          = merge(local.default-tags, var.tags)
  type          = lookup(var.analyzer, "type", local.default_iam_access_analyzer["type"])
}
