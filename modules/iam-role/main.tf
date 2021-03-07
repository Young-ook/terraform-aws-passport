data "aws_caller_identity" "current" {
  count = var.enabled ? 1 : 0
}

# iam role module
resource "aws_iam_role" "role" {
  count                = var.enabled ? 1 : 0
  name                 = local.name
  path                 = local.namespace
  tags                 = merge(local.default-tags, var.tags)
  max_session_duration = var.session_duration
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        AWS = distinct(flatten([
          data.aws_caller_identity.current.0.account_id,
          var.trusted_roles,
        ]))
      }
    }]
    Version = "2012-10-17"
  })
}

# security/policy
resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = { for key, val in var.policies : key => val if var.enabled }
  policy_arn = each.value
  role       = aws_iam_role.role.0.name
}
