### managed identity provider service

locals {
  aws = {
    region  = module.aws.region.name
    account = module.aws.caller.account_id
    dns     = module.aws.partition.dns_suffix
  }
}

# security/policy
resource "aws_iam_role" "cognito" {
  name = local.name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = [format("cognito-idp.%s", local.aws.dns)]
      }
    }]
  })
}

resource "aws_iam_policy" "pub-sns" {
  name        = join("-", [local.name, "publish-sns"])
  description = format("Allow Cognito to send SMS")
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["sns:publish"]
      Effect   = "Allow"
      Resource = ["*"]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "pub-sns" {
  policy_arn = aws_iam_policy.pub-sns.arn
  role       = aws_iam_role.cognito.id
}

resource "aws_iam_role" "auth" {
  name = join("-", [local.name, "signed-users"])
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = [format("cognito-identity.%s", local.aws.dns)]
      }
      Condition = {
        "StringEquals" = {
          format("cognito-identity.%s:aud", local.aws.dns) = aws_cognito_identity_pool.idp.id
        }
        "ForAnyValue:StringLike" = {
          format("cognito-identity.%s:amr", local.aws.dns) = "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "auth" {
  for_each = {
    for k, v in concat(
      [aws_iam_policy.cognito-identity.arn, aws_iam_policy.cognito-sync.arn, ],
      lookup(var.policy_arns, "authenticated", [])
    ) : k => v
  }
  policy_arn = each.value
  role       = aws_iam_role.auth.name
}

resource "aws_iam_role" "unauth" {
  name = join("-", [local.name, "anonymous-users"])
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = [format("cognito-identity.%s", local.aws.dns)]
      }
      Condition = {
        "StringEquals" = {
          format("cognito-identity.%s:aud", local.aws.dns) = aws_cognito_identity_pool.idp.id
        }
        "ForAnyValue:StringLike" = {
          format("cognito-identity.%s:amr", local.aws.dns) = "unauthenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "unauth" {
  for_each = {
    for k, v in concat(
      [aws_iam_policy.cognito-identity.arn, ],
      lookup(var.policy_arns, "unauthenticated", [])
    ) : k => v
  }
  policy_arn = each.value
  role       = aws_iam_role.unauth.name
}

resource "aws_iam_policy" "cognito-identity" {
  name = join("-", [local.name, "cognito-identity"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["cognito-identity:*", ]
        Effect   = "Allow"
        Resource = [aws_cognito_identity_pool.idp.arn]
      }
    ]
  })
}

resource "aws_iam_policy" "cognito-sync" {
  name = join("-", [local.name, "cognito-sync"])
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["cognito-sync:*", ]
        Effect   = "Allow"
        Resource = [replace(aws_cognito_identity_pool.idp.arn, "cognito-identity", "cognito-sync")]
      }
    ]
  })
}

# security/idp
resource "aws_cognito_user_pool" "idp" {
  name                     = replace(local.name, "-", "_")
  tags                     = merge(local.default-tags, var.tags)
  auto_verified_attributes = local.default_auto_verified_attributes
  mfa_configuration        = "OFF"

  sms_configuration {
    external_id    = random_string.extid.result
    sns_caller_arn = aws_iam_role.cognito.arn
  }

  dynamic "schema" {
    for_each = { for schema in local.default_profile_schema : schema.name => schema }
    content {
      attribute_data_type      = lookup(schema.value, "attribute_data_type", null)
      developer_only_attribute = lookup(schema.value, "developer_only_attribute", null)
      mutable                  = lookup(schema.value, "mutable")
      name                     = lookup(schema.value, "name")
      required                 = lookup(schema.value, "required", false)

      dynamic "string_attribute_constraints" {
        for_each = { for k, v in schema.value : k => v if k == "string_attribute_constraints" }
        content {
          min_length = lookup(string_attribute_constraints.value, "min_length", 0)
          max_length = lookup(string_attribute_constraints.value, "max_length", 1)
        }
      }
    }
  }
}

resource "aws_cognito_user_pool_client" "idp" {
  name            = local.name
  user_pool_id    = aws_cognito_user_pool.idp.id
  generate_secret = false
}

resource "aws_cognito_identity_pool_roles_attachment" "idp" {
  identity_pool_id = aws_cognito_identity_pool.idp.id
  roles = {
    authenticated   = aws_iam_role.auth.arn
    unauthenticated = aws_iam_role.unauth.arn
  }
}

resource "aws_cognito_identity_pool" "idp" {
  identity_pool_name               = replace(local.name, "-", "_")
  allow_unauthenticated_identities = true
  cognito_identity_providers {
    client_id     = aws_cognito_user_pool_client.idp.id
    provider_name = aws_cognito_user_pool.idp.endpoint
  }
}
