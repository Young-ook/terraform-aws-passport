output "idp" {
  description = "Attributes of Cognito IdP"
  value = {
    idp_id        = aws_cognito_identity_pool.idp.id
    idp_arn       = aws_cognito_identity_pool.idp.arn
    client_id     = aws_cognito_user_pool_client.idp.id
    endpoint      = aws_cognito_user_pool.idp.endpoint
    user_pool_arn = aws_cognito_user_pool.idp.arn
    user_pool_id  = aws_cognito_user_pool.idp.id
  }
}
