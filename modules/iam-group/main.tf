# feature
locals {
  assume_role_enabled = var.target_roles != null ? (length(var.target_roles) > 0 ? true : false) : false
}

# iam group module
resource "aws_iam_group" "group" {
  count = var.enabled ? 1 : 0
  name  = local.name
  path  = local.namespace
}

# security/policy
resource "aws_iam_policy" "assume" {
  count = local.assume_role_enabled && var.enabled ? 1 : 0
  name  = join("-", [local.name, "assume"])
  policy = jsonencode({
    Statement = [{
      Action   = "sts:AssumeRole"
      Effect   = "Allow"
      Resource = var.target_roles
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_group_policy_attachment" "assume" {
  count      = local.assume_role_enabled && var.enabled ? 1 : 0
  policy_arn = aws_iam_policy.assume.0.arn
  group      = aws_iam_group.group.0.name
}

resource "aws_iam_group_policy_attachment" "policy" {
  for_each   = { for key, val in var.policies : key => val if var.enabled }
  policy_arn = each.value
  group      = aws_iam_group.group.0.name
}
