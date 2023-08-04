### security/role
resource "aws_iam_role" "role" {
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
          module.aws.caller.account_id,
          var.trusted_roles,
        ]))
      }
    }]
    Version = "2012-10-17"
  })
}

### security/policy
resource "aws_iam_role_policy_attachment" "policy" {
  for_each   = { for k, v in var.policy_arns : k => v }
  policy_arn = each.value
  role       = aws_iam_role.role.name
}
