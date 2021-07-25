# Passport
Passport is a terraform module for Cross-Account Identity and Access Management on AWS. For more details, please visit the [Passport](https://github.com/Young-ook/terraform-aws-passport) project page.

## Bespoke account(s)
Bespoke AWS account is an account that we create for a specific purpose whthin the passport architecture. Bespoke allows users of the badge account, identity gateway, to assume into roles in bespoke account, such as adminstrator, data scientist, developer. Those roles in bespoke account can only be access by badge account users.

## Badge account
Badge AWS account is an identity gateway in a passport architecture where all user-role mappings accross accounts are managed.

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/bespoke
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/bespoke/main.tf) is an example of terraform configuration file to create identity gateway account with baseline security policies. To build your AWS account as a badge account, clone the example and run terraform apply.

Run terraform:
```sh
terraform init
```

First, we have to create a `badge` account for baseline.
```sh
terraform apply --target module.badge
```

Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan --target module.badge -var-file tc1.tfvars
terraform apply --target module.badge -var-file tc1.tfvars
```

Next, run terraform apply to create roles to the `bespoke` account. The developer role with read-only access policy and the rescue role with admin access policy will be created in the bespoke account for your application deployment.
```sh
terraform apply --target module.bespoke
```

Finally, run the following command to associate the resources created in each account in the previous step. This command updates the user-group-role mapping in the badge account.
```sh
terraform apply
```
This module creates users and groups in the `badge` account with group and role mappings. And also, it creates roles in the `bespoke` account for cross-role switching. However, in this example, we are using the same aws account for simple testing.

## Verify
This example creates a user in your badge account. The name of user is `developer` who can switch to a rescue or a developer in the bespoke account.

Don't forget after the first login your IAM user, you must enable MFA (Multi-Factor Authenticator) in your account before you switch a role.

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
