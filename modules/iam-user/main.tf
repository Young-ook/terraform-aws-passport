# feature
locals {
  login_enabled = lookup(var.features, "login", false)
}

# iam user module
resource "aws_iam_user" "user" {
  name          = local.name
  path          = local.namespace
  tags          = merge(local.default-tags, var.tags)
  force_destroy = true
}

# security/policy
resource "aws_iam_user_policy_attachment" "policy" {
  for_each   = { for k, v in var.policy_arns : k => v }
  user       = aws_iam_user.user.name
  policy_arn = var.policy_arns[each.value]
}

# group membership
resource "aws_iam_user_group_membership" "groups" {
  user   = aws_iam_user.user.name
  groups = var.groups
}

# security/password
resource "random_password" "password" {
  length           = lookup(var.password_policy, "length", 16)
  special          = true
  override_special = "!@#$%^&*()_+-=[]{}|'"
}

locals {
  login_profile_skaffold = {
    UserName = aws_iam_user.user.name
    Password = random_password.password.result
    PasswordResetRequired : true
  }
}

data "aws_region" "current" {}

resource "null_resource" "login-profile" {
  for_each = toset(local.login_enabled ? ["awscli"] : [])
  provisioner "local-exec" {
    command = "aws iam create-login-profile --cli-input-json $JSON --region $AWS_REGION"
    environment = {
      JSON       = jsonencode(local.login_profile_skaffold)
      AWS_REGION = data.aws_region.current.name
    }
  }
}
