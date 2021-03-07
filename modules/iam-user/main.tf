# feature
locals {
  login_enabled = lookup(var.features, "login", false)
}

# iam user module
resource "aws_iam_user" "user" {
  count         = var.enabled ? 1 : 0
  name          = local.name
  path          = local.namespace
  tags          = merge(local.default-tags, var.tags)
  force_destroy = true
}

# security/policy
resource "aws_iam_user_policy_attachment" "policy" {
  for_each   = { for key, val in var.policy_arns : key => val if var.enabled }
  user       = aws_iam_user.user.0.name
  policy_arn = var.policy_arns[each.value]
}

# group membership
resource "aws_iam_user_group_membership" "groups" {
  count  = var.enabled ? 1 : 0
  user   = aws_iam_user.user.0.name
  groups = var.groups
}

# security/password
resource "random_password" "password" {
  count            = var.enabled ? 1 : 0
  length           = lookup(var.password_policy, "length", 16)
  special          = true
  override_special = "!@#$%^&*()_+-=[]{}|'"
}

locals {
  login_profile_skaffold = var.enabled ? {
    UserName = aws_iam_user.user.0.name
    Password = random_password.password.0.result
    PasswordResetRequired : true
  } : null
}

data "aws_region" "current" {
  count = var.enabled ? 1 : 0
}

resource "null_resource" "login-profile" {
  count = local.login_enabled && var.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "aws iam create-login-profile --cli-input-json $JSON --region $AWS_REGION"
    environment = {
      JSON       = jsonencode(local.login_profile_skaffold)
      AWS_REGION = data.aws_region.current.0.name
    }
  }
}
