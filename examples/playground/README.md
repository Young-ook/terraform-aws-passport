# Terraform Skill Playground
This is a sandbox environment to test terraform code. With this playground, you can test or learn on how to use terraform functions such as file(), concat(), merge() without impact.

## Setup
### Prerequisites
This example terraform command line tool. If you don't have the terraform in your environment, go to the main [page](https://github.com/Young-ook/terraform-aws-passport) of this repository and follow the installation instructions.

### Download
Download this example on your workspace
```
git clone https://github.com/Young-ook/terraform-aws-passport
cd terraform-aws-passport/examples/playground
```

Then you are in **playground** directory under your current workspace. There is an exmaple that shows how to use terraform configurations to manipulate datas for infrastructure resources. Please make sure that you have installed the terraform in your workspace before moving to the next step.

Run terraform:
```
terraform init
terraform apply
```

## Clean up
To destroy all infrastrcuture, run terraform:
```
terraform destroy
```

If you don't want to see a confirmation question, you can use quite option for terraform destroy command
```
terraform destroy --auto-approve
```

**[DON'T FORGET]** You have to use the *-var-file* option when you run terraform destroy command to delete the aws resources created with extra variable files.
```
terraform destroy -var-file fixture.tc1.tfvars
```
