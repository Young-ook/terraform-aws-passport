# default variables

locals {
  default_config_rules = [
    {
      name                        = "cloudtrail-enabled"
      description                 = "Ensure CloudTrail is enabled"
      maximum_execution_frequency = "TwentyFour_Hours"
      source = {
        owner             = "AWS"
        source_identifier = "CLOUD_TRAIL_ENABLED"
      }
    },
    {
      name                        = "iam-pw-policy"
      description                 = "Ensure the account password policy for IAM users meets the specified requirements"
      input_parameters            = jsonencode({})
      maximum_execution_frequency = "TwentyFour_Hours"
      source = {
        owner             = "AWS"
        source_identifier = "IAM_PASSWORD_POLICY"
      }
    },
    {
      name        = "ec2-vpc"
      description = "Ensure all EC2 instances run in a VPC"
      source = {
        owner             = "AWS"
        source_identifier = "INSTANCES_IN_VPC"
      }
    },
    {
      name                        = "root-mfa-enabled"
      description                 = "Ensure root AWS account has MFA enabled"
      maximum_execution_frequency = "TwentyFour_Hours"
      source = {
        owner             = "AWS"
        source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
      }
    },
    {
      name                        = "acm-expiration-check"
      description                 = "Ensures ACM Certificates in your account are marked for expiration within the specified number of days"
      input_parameters            = jsonencode({})
      maximum_execution_frequency = "TwentyFour_Hours"
      source = {
        owner             = "AWS"
        source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
      }
    },
    {
      name        = "ebs-inuse-check"
      description = "Checks whether EBS volumes are attached to EC2 instances"
      source = {
        owner             = "AWS"
        source_identifier = "EC2_VOLUME_INUSE_CHECK"
      }
    },
    {
      name        = "ec2-imdsv2-check"
      description = "Checks if EC2 instances metadata is configured with IMDSv2 or not"
      source = {
        owner             = "AWS"
        source_identifier = "EC2_IMDSV2_CHECK"
      }
    },
    {
      name        = "rds-encrypted"
      description = "Checks whether storage encryption is enabled for your RDS DB instances."
      source = {
        owner             = "AWS"
        source_identifier = "RDS_STORAGE_ENCRYPTED"
      }
    },
    {
      name        = "rds-private"
      description = "Checks whether the Amazon Relational Database Service (RDS) instances are not publicly accessible. The rule is non-compliant if the publiclyAccessible field is true in the instance configuration item."
      source = {
        owner             = "AWS"
        source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
      }
    },
    {
      name        = "rds-private-snapshots"
      description = "Checks if Amazon Relational Database Service (Amazon RDS) snapshots are public."
      source = {
        owner             = "AWS"
        source_identifier = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
      }
    },
    {
      name        = "required-tags"
      description = "Checks if resources are deployed with configured tags."
      input_parameters = jsonencode({
        tag1Key = "terraform.io"
        tag2Key = "environment"
      })
      scope = {
        compliance_resource_types = [
          "S3::Bucket"
        ]
      }
      source = {
        owner             = "AWS"
        source_identifier = "REQUIRED_TAGS"
      }
    },
  ]
}
