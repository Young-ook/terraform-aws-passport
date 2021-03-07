### badge for individual user
module "badge-group" {
  source    = "./modules/iam-group"
  name      = "badge"
  namespace = var.namespace
  tags      = var.tags
  policies = [
    aws_iam_policy.force-mfa.arn,
    aws_iam_policy.creds-self.arn,
  ]
}

# security/policy
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
# Force MFA for all users
resource "aws_iam_policy" "force-mfa" {
  name   = "badge-force-mfa"
  policy = <<FORCE_MFA
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "DenyAllExceptListedIfNoMFA",
            "Effect": "Deny",
            "NotAction": [
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:ChangePassword",
                "iam:GetUser",
                "iam:ListMFADevices",
                "iam:ListVirtualMFADevices",
                "iam:ResyncMFADevice",
                "sts:GetSessionToken"
            ],
            "Resource": "*",
            "Condition": {
                "BoolIfExists": {
                    "aws:MultiFactorAuthPresent": "false"
                }
            }
        }
    ]
}
FORCE_MFA
}

# security/policy
# https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
# Allows IAM users to manage their own credentials
resource "aws_iam_policy" "creds-self" {
  name   = "badge-creds-self"
  policy = <<CREDS_SELF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowViewAccountInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetAccountPasswordPolicy",
                "iam:GetAccountSummary",
                "iam:GetAccessKeyLastUsed",
                "iam:ListVirtualMFADevices"
            ],
            "Resource": "*"
        },
        {
            "Sid": "AllowManageOwnPasswords",
            "Effect": "Allow",
            "Action": [
                "iam:ChangePassword",
                "iam:GetUser"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnAccessKeys",
            "Effect": "Allow",
            "Action": [
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:ListAccessKeys",
                "iam:UpdateAccessKey"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnSigningCertificates",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteSigningCertificate",
                "iam:ListSigningCertificates",
                "iam:UpdateSigningCertificate",
                "iam:UploadSigningCertificate"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnSSHPublicKeys",
            "Effect": "Allow",
            "Action": [
                "iam:DeleteSSHPublicKey",
                "iam:GetSSHPublicKey",
                "iam:ListSSHPublicKeys",
                "iam:UpdateSSHPublicKey",
                "iam:UploadSSHPublicKey"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnGitCredentials",
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceSpecificCredential",
                "iam:DeleteServiceSpecificCredential",
                "iam:ListServiceSpecificCredentials",
                "iam:ResetServiceSpecificCredential",
                "iam:UpdateServiceSpecificCredential"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnVirtualMFADevice",
            "Effect": "Allow",
            "Action": [
                "iam:CreateVirtualMFADevice",
                "iam:DeleteVirtualMFADevice"
            ],
            "Resource": "arn:aws:iam::*:mfa/$${aws:username}"
        },
        {
            "Sid": "AllowManageOwnUserMFA",
            "Effect": "Allow",
            "Action": [
                "iam:DeactivateMFADevice",
                "iam:EnableMFADevice",
                "iam:ListMFADevices",
                "iam:ResyncMFADevice"
            ],
            "Resource": "arn:aws:iam::*:user${local.namespace}$${aws:username}"
        }
    ]
}
CREDS_SELF
}

### security/admin
module "security-group" {
  source       = "./modules/iam-group"
  name         = "security"
  namespace    = var.namespace
  tags         = var.tags
  target_roles = [module.role["security"].role.arn]
}

### security/audit
module "audit-group" {
  source       = "./modules/iam-group"
  name         = "audit"
  namespace    = var.namespace
  tags         = var.tags
  target_roles = [module.role["audit"].role.arn]
}

locals {
  roles = [
    ### security/audit
    {
      name      = "audit"
      namespace = var.namespace
      tags      = var.tags
      policies = [
        "arn:aws:iam::aws:policy/SecurityAudit"
      ]
    },
    ### security/admin
    {
      name      = "security"
      namespace = var.namespace
      tags      = var.tags
      policies = [
        "arn:aws:iam::aws:policy/IAMFullAccess",
      ]
    }
  ]
}

module "role" {
  for_each      = { for role in local.roles : role.name => role }
  source        = "./modules/iam-role"
  name          = lookup(each.value, "name")
  namespace     = lookup(each.value, "namespace")
  tags          = lookup(each.value, "tags")
  policies      = lookup(each.value, "policies", [])
  trusted_roles = lookup(each.value, "trusted_roles", [])
}
