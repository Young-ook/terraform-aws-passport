# Passport
Passport is a terraform module for Cross-Account Identity and Access Management on AWS. For more details, please visit the [Passport](https://github.com/Young-ook/terraform-aws-passport) project page.

## Setup
This is an example to explain how to build and deploy badge and bespoke accounts. And it shows that how to add users and manage the policy to give access to them via terraform configuration. [This](main.tf) is the example of terraform configuration file to create IAM users, groups and role on multiple AWs accounts. Check out and apply it using terraform command.

### Create a badge account
First, we have to build a badge account for baseline of identity gateway.

Run terraform:
```
terraform init
terraform apply -target module.badge
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform plan -var-file -target module.badge tc1.tfvars
terraform apply -var-file -target module.badge tc1.tfvars
```

### Create a bespoke account
Run terraform:
```
terraform init
terraform apply -target module.analytics
```
After all, you will see the generated IAM roles on the `bespoke` accounts.
If you have customized your variables using the `-var-files` option in the previous step, you must use the same parameters in this step as well.
```
terraform plan -var-file -target module.analytics tc1.tfvars
terraform apply -var-file -target module.analytics tc1.tfvars
```

### Create IAM users
Run terraform:
```
terraform init
terraform apply
```
This command will create users and groups on the `badge` account with group and role mappings. After applying this, individual users will have access to their IAM user in the `badge` account for cross-account role switching.

## Clean up
Run terraform:
```
$ terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
$ terraform destroy -var-file tc1.tfvars
```