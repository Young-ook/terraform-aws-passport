# Baseline

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/baseline
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/baseline/main.tf) is an example of terraform configuration file to create identity gateway account with baseline security policies. To build your AWS account as a badge account, clone the example and run terraform apply.

Run terraform:
```sh
terraform init
terraform apply
```
This module creates roles in the `bespoke` account for cross-role switching and baseline security rules to prevent disallowed software package installation.

## Verify

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
