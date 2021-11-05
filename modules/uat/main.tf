module "event" {
  for_each    = local.event_config
  source      = "Young-ook/lambda/aws//modules/events"
  name        = join("-", [var.name, each.key])
  tags        = var.tags
  rule_config = each.value.rule_config
}

resource "aws_cloudwatch_event_target" "lambda" {
  for_each = local.event_config
  rule     = module.event[each.key].eventbridge.rule.name
  arn      = module.lambda.function.arn
}

resource "aws_lambda_permission" "lambda" {
  for_each      = local.event_config
  source_arn    = module.event[each.key].eventbridge.rule.arn
  function_name = module.lambda.function.id
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
}

# lambda
module "lambda" {
  source         = "Young-ook/lambda/aws"
  name           = var.name
  tags           = var.tags
  lambda_config  = var.lambda_config
  tracing_config = var.tracing_config
  vpc_config     = var.vpc_config
  policy_arns    = [module.logs.policy_arns["write"]]
}

# cloudwatch logs
module "logs" {
  source     = "Young-ook/lambda/aws//modules/logs"
  name       = var.name
  tags       = var.tags
  log_config = var.log_config
}
