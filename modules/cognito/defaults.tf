### default values

### aws partitions
module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  aws = {
    dns       = module.aws.partition.dns_suffix
    partition = module.aws.partition.partition
    region    = module.aws.region.name
    id        = module.aws.caller.account_id
  }
}

locals {
  default_auto_verified_attributes = ["email"]
  default_profile_schema = [
    {
      name                = "email"
      attribute_data_type = "String"
      mutable             = false
      required            = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
    {
      name                = "phone_number"
      attribute_data_type = "String"
      mutable             = false
      required            = false
      string_attribute_constraints = {
        min_length = 1
        max_length = 20
      }
    },
    {
      name                = "profile_user_id"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
    {
      name                = "profile_email"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
    {
      name                = "profile_first_name"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
    {
      name                = "profile_last_name"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
    {
      name                = "profile_gender"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 10
      }
    },
    {
      name                = "profile_age"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 3
      }
    },
    {
      name                = "profile_persona"
      attribute_data_type = "String"
      mutable             = true
      string_attribute_constraints = {
        min_length = 1
        max_length = 200
      }
    },
  ]
}
