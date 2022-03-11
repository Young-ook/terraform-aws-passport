module "event" {
  for_each = { for r in var.rules : r.name => r }
  source   = "Young-ook/lambda/aws//modules/eventbridge"
  version  = "0.1.4"
  name     = join("-", [var.name, each.key])
  tags     = var.tags
  rule     = each.value
}

resource "aws_cloudwatch_event_target" "lambda" {
  for_each = { for r in var.rules : r.name => r }
  rule     = module.event[each.key].rule.name
  arn      = module.lambda.function.arn
}

resource "aws_lambda_permission" "lambda" {
  for_each      = { for r in var.rules : r.name => r }
  source_arn    = module.event[each.key].rule.arn
  function_name = module.lambda.function.id
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
}

# lambda
module "lambda" {
  source      = "Young-ook/lambda/aws"
  version     = "0.1.4"
  name        = var.name
  tags        = var.tags
  lambda      = var.lambda
  tracing     = var.tracing
  vpc         = var.vpc
  policy_arns = [module.logs.policy_arns["write"]]
}

# cloudwatch logs
module "logs" {
  source    = "Young-ook/lambda/aws//modules/logs"
  version   = "0.1.4"
  name      = var.name
  tags      = var.tags
  log_group = var.log
}
