# Passport
[Passport](https://github.com/Young-ook/terraform-aws-passport) is a project for fine-grained multi-aws account role switching platform. It supports baseline security policies and best practicies. There is identity gateway account we called `badge` account for management of user identity and group membership to allow users to assume to the authorized role in the target AWS account. The target account we called `bespoke` account is purpose built AWS account. We can transform that account to run the production environment resources only. Also, we can make the bespoke account to the control tower of the whole network configuration for the organization. In this case, allowed administators can touch the VPC resources and share them to the other `bespoke` accounts to use them. Passport is very flexible for categorization of AWS acouunt to meet the requirement from organization.

![aws-multi-account-passport-architecture](images/aws-multi-account-passport-architecture.png)

Individual users can assume cross-account roles defined in IAM policies attached to IAM groups in the `badge` account. For example, if a user belongs to the `DataScientist` IAM group in the `badge` account, the user can switch to the `DataScientist` role in the `Data Analytics` account if there is a policy to assume that role. In this case, `Data Analytics` is one of the `bespoke` accounts. You can also create `Developer` role to give sandbox accounts full access, but restrict access to production environments.

What is important thing in this system is that only `Security` role can manage role mapping rules for the `badge` account. Recommend 3 users to have `Security` role for applying configuration and policy changes. It is necessary to establish a rule so that the permission policy can be updated only with the approval of at least 1 out of 3 security engineers.

## Examples
- [Single-Account RBAC with AWS IAM](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/badge)
- [Multi-Account RBAC with AWS IAM](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/rbac)
- [Role Switching Activity Tracker](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/role-switching-tracker)
- [Baseline for Compliance](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/baseline)
- [Terraform Playground](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/playground)
- [Single-Account ABAC with AWS IAM](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/abac)
- [Amazon Cognito Identity Provider](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/cognito)

## Getting started
### AWS CLI
:warning: **This module requires the aws cli version 2.5.8 or higher**

Follow the official guide to install and configure profiles.
- [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)

After the installation is complete, you can check the aws cli version:
```
aws --version
aws-cli/2.5.8 Python/3.9.11 Darwin/21.4.0 exe/x86_64 prompt/off
```

### Terraform
Terraform is an open-source infrastructure as code software tool that enables you to safely and predictably create, change, and improve infrastructure.

#### Install
This is the official guide for terraform binary installation. Please visit this [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) website and follow the instructions.

Or, you can manually get a specific version of terraform binary from the websiate. Move to the [Downloads](https://www.terraform.io/downloads.html) page and look for the appropriate package for your system. Download the selected zip archive package. Unzip and install terraform by navigating to a directory included in your system's `PATH`.

Or, you can use [tfenv](https://github.com/tfutils/tfenv) utility. It is very useful and easy solution to install and switch the multiple versions of terraform-cli.

First, install tfenv using brew.
```
brew install tfenv
```
Then, you can use tfenv in your workspace like below.
```
tfenv install <version>
tfenv use <version>
```
Also this tool is helpful to upgrade terraform v0.12. It is a major release focused on configuration language improvements and thus includes some changes that you'll need to consider when upgrading. But the version 0.11 and 0.12 are very different. So if some codes are written in older version and others are in 0.12 it would be great for us to have nice tool to support quick switching of version.
```
tfenv list
tfenv install latest
tfenv use <version>
```

# Additional Resources
- [AWS re:Invent 2022 - Reimagining multi-account deployments for security and speed (NFX305)](https://youtu.be/MKc9r6xOTpk)
