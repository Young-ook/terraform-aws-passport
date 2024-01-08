### default values

module "aws" {
  source = "Young-ook/spinnaker/aws//modules/aws-partitions"
}

locals {
  default_iam_access_analyzer = {
    type = "ACCOUNT" # allowed values: ORGANIZATION | ACCOUNT
  }
}
