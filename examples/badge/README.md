# Passport
Passport is a terraform module for Cross-Account Identity and Access Management on AWS. For more details, please visit the [Passport](https://github.com/Young-ook/terraform-aws-passport) project page.

## Badge account
Badge AWS account is an identity gateway in a passport architecture where all user-role mappings accross accounts are managed. 

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/badge
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/badge/main.tf) is an example of terraform configuration file to create identity gateway account with baseline security policies. To build your AWS account as a badge account, clone the example and run terraform apply.

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

This command will create users and groups on the `badge` account with group and role mappings. After applying this, individual users will have access to base line roles and polcies.

## Verify
This example creates two users in your badge account. The name of one user is `security-officer` who can switch a security administrator role that it can manage all user-role mappings in the badge account. The other one is `developer`. This user can not switch to an internal or cross-account role.

Don't forget after the first login your IAM user, you must enable MFA (Multi-Factor Authenticator) in your account before you switch a role.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file tc1.tfvars
```