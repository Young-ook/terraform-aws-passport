## secret manager

### parameters
locals {}

### security/policy
resource "aws_iam_policy" "read" {
  name        = format("%s-read", local.name)
  description = format("Allow to get secrets")
  path        = "/"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
        ]
        Effect   = "Allow"
        Resource = [aws_secretsmanager_secret.secret.arn]
      },
      {
        Action = [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets",
        ]
        Effect   = "Allow"
        Resource = ["*"]
      }
    ]
  })
}

### security/secret
resource "aws_secretsmanager_secret" "secret" {
  name = local.name
  tags = var.tags
  #policy = var.policy
}

resource "aws_secretsmanager_secret_version" "secret" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = var.secret
}
