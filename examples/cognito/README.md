# Amazon Cognito

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/cognito
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/cognito/main.tf) is the example of terraform configuration file to create Amazon Cognito Identity Provider (IdP) service. Check out and apply it using terraform command.

## Terraform
Run terraform:
```
terraform init
terraform apply
```
Also you can use the `-var-file` option for customized paramters when you run the terraform plan/apply command.
```
terraform apply -var-file fixture.tc1.tfvars
```

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```
