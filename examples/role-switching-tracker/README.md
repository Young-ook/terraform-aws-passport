# Role Switching Tracker for Passport
Passport is a terraform module for Cross-Account Identity and Access Management on AWS. For more details, please visit the [Passport](https://github.com/Young-ook/terraform-aws-passport) project page. Badge AWS account is an identity gateway in a passport architecture where all user-role mappings accross accounts are managed.

This ia a user activity (especially role switching with administrative roles) tracker for the passport project. This example uses Amazon EventBridge to detect an IAM role switching event, such as an IAM API call, and uses AWS Lambda function to send a notification via Slack. In this example uses `aws-events` module to build predefined application for AWS Event management. For more details, please visit the [page](https://github.com/Young-ook/terraform-aws-passport/blob/main/modules/aws-events).

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/role-switching-tracker
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/role-switching-tracker/main.tf) is an example of terraform configuration file to create identity gateway account with baseline security policies and role switching tracker.

If you don't have the terraform and kubernetes tools in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-passport) of this repository and follow the installation instructions.

Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file tc1.tfvars
terraform apply -var-file tc1.tfvars
```

This command will create users and groups on the `badge` account with group and role mappings. And it also, creates event-driven application with Amazon EventBridge and Lambda to track user acitivities.

In this example, slack integration requires two sensitive credentials: `slack webhook url` and `slack channel id`. Prepare your credentials before running this example and pass them to the variable when running terraform apply with a custom variable.

For more details about how to protect your sensitive variables using terraform, please refer to this [document](https://learn.hashicorp.com/tutorials/terraform/sensitive-variables?in=terraform/0-14).

## Verify
This example creates a developer which belongs two groups for role switching in your badge account. The developer user can assume role to the `develper` or `rescue` after enabling MFA (Multi-Factor Authenticator). Don't forget after the first login your IAM user, you must enable MFA in your account before you switch a role.

To test if the user activity tracker is working well, try to sign-in as a developer user with MFA token. Then, change your role by following this [guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html).

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
