## aws partitions
module "current" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

## aws config
# security/policy
resource "aws_iam_role" "awsconfig" {
  name = local.name
  tags = merge(local.default-tags, var.tags)
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = format("config.%s", module.current.partition.dns_suffix)
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "awsconfig" {
  policy_arn = format("arn:%s:iam::aws:policy/service-role/AWS_ConfigRole", module.current.partition.partition)
  role       = aws_iam_role.awsconfig.id
}

resource "aws_iam_role_policy_attachment" "snapshot" {
  policy_arn = module.snapshot.policy_arns.write
  role       = aws_iam_role.awsconfig.id
}

resource "aws_iam_role_policy" "noti" {
  name = join("-", [local.name, "sns-publish"])
  role = aws_iam_role.awsconfig.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["SNS:Publish"]
      Resource = [aws_sns_topic.noti.arn]
    }]
  })
}

# recorder
# compliance/audit
module "snapshot" {
  source        = "Young-ook/sagemaker/aws//modules/s3"
  name          = local.name
  tags          = merge(local.default-tags, var.tags)
  force_destroy = true
}

resource "aws_config_configuration_recorder" "recorder" {
  depends_on = [module.snapshot]
  name       = local.name
  role_arn   = aws_iam_role.awsconfig.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "recorder" {
  depends_on = [aws_config_delivery_channel.recorder]
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}

resource "aws_config_delivery_channel" "recorder" {
  depends_on     = [aws_config_configuration_recorder.recorder]
  name           = local.name
  s3_bucket_name = module.snapshot.bucket.id
  s3_key_prefix  = "awsconfig/records"
  sns_topic_arn  = aws_sns_topic.noti.arn

  /*
  dynamic "snapshot_delivery_properties" {
    for_each = { for k, v in [lookup(var.record_config, "snapshot_delivery_properties", {})] : k => v }
    content {
      delivery_frequency = lookup(snapshot_delivery_properties.value, "delivery_frequency", "Three_Hours") # default: 3 hours
    }
  }
  */
}

# compliance/rules
resource "aws_config_config_rule" "rules" {
  depends_on                  = [aws_config_configuration_recorder_status.recorder]
  for_each                    = { for rule in local.default_config_rules : rule.name => rule }
  name                        = each.key
  tags                        = merge(local.default-tags, var.tags)
  description                 = lookup(each.value, "description", null)
  maximum_execution_frequency = lookup(each.value, "maximum_execution_frequency", null)
  input_parameters            = lookup(each.value, "input_parameters", null)

  source {
    owner             = lookup(each.value.source, "owner")
    source_identifier = lookup(each.value.source, "source_identifier")
  }

  dynamic "scope" {
    for_each = { for k, v in [lookup(each.value, "scope", {})] : k => v }
    content {
      compliance_resource_types = lookup(scope.value, "compliance_resource_types", [])
    }
  }
}

# notification
resource "aws_sns_topic" "noti" {
  name = local.name
}
