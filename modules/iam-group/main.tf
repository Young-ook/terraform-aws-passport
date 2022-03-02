# feature
locals {
  assume_role_enabled = var.target_roles != null ? (length(var.target_roles) > 0 ? true : false) : false
}

# iam group module
resource "aws_iam_group" "group" {
  name = local.name
  path = local.namespace
}

# security/policy
resource "aws_iam_policy" "assume" {
  for_each = toset(local.assume_role_enabled ? ["assume"] : [])
  name     = join("-", [local.name, "assume"])
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
  for_each   = toset(local.assume_role_enabled ? ["assume"] : [])
  policy_arn = aws_iam_policy.assume["assume"].arn
  group      = aws_iam_group.group.name
}

resource "aws_iam_group_policy_attachment" "policy" {
  for_each   = { for k, v in var.policy_arns : k => v }
  policy_arn = each.value
  group      = aws_iam_group.group.name
}
