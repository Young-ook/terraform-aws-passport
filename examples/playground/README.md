# Terraform Skill Playground
This is a sandbox environment to test terraform code. You can test or learn on how to use terraform functions such as file(), concat(), merge() without impact.

## Download example
Download this example on your workspace
```sh
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/playground
```

## Setup
[This](https://github.com/Young-ook/terraform-aws-passport/blob/main/examples/playground/main.tf) is an example of terraform configuration file for rich scripting with terraform functions. Clone the example and run terraform apply.

Run terraform:
```sh
terraform init
terraform apply
```

## Clean up
Run terraform:
```
terraform destroy
```
Don't forget you have to use the `-var-file` option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file tc1.tfvars
```
