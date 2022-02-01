# Baseline

terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account]
}

### A spoke account is an AWS account for application or purpose built account.
locals {
  bespoke_roles = [
    {
      name      = "security-guard"
      namespace = var.namespace
      tags      = var.tags
      policy_arns = [
        "arn:aws:iam::aws:policy/AdministratorAccess",
      ]
    },
  ]
}

module "bespoke" {
  for_each      = { for role in local.bespoke_roles : role.name => role }
  source        = "Young-ook/passport/aws//modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policy_arns   = lookup(each.value, "policy_arns", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}

### baseline rules
resource "aws_ssm_document" "cwagent" {
  name            = "Install-CloudWatch-Agent"
  document_format = "YAML"
  document_type   = "Command"
  content         = file("${path.module}/templates/cwagent.yaml")
}

resource "aws_ssm_association" "cwagent" {
  name             = aws_ssm_document.cwagent.name
  association_name = "install-cloudwatch-agent"
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

resource "aws_ssm_association" "patch-baseline" {
  name             = "AWS-RunPatchBaseline"
  association_name = "weekly-patch-baseline"
  parameters = {
    Operation = "Install"
  }
  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

resource "random_pet" "ruleslog" {
  length    = 3
  separator = "-"
}

module "rules" {
  source = "../../modules/aws-config"
  name   = var.name
  tags   = var.tags
}
