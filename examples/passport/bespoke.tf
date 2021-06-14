### bespoke account guardrails
provider "aws" {
  alias               = "bespoke"
  region              = var.aws_region
  allowed_account_ids = [var.aws_account]
}

module "analytics" {
  providers   = { aws = aws.bespoke }
  source      = "./modules/bespoke"
  name        = var.name
  tags        = var.tags
  aws_account = var.aws_account
  namespace   = var.namespace
}