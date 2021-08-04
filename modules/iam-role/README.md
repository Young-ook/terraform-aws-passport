# IAM Role
An IAM [role](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html) is an IAM identity that you can create in your account that has specific permissions. An IAM role is similar to an IAM user, in that it is an AWS identity with permission policies that determine what the identity can and cannot do in AWS. However, instead of being uniquely associated with one person, a role is intended to be assumable by anyone who needs it. Also, a role does not have standard long-term credentials such as a password or access keys associated with it. Instead, when you assume a role, it provides you with temporary security credentials for your role session.

## Example
This is simple example of iam-role submodule of passport project.

```hcl
module "infra-engineer" {
  source     = "Young-ook/passport/aws//modules/iam-role"
  name       = "infra-engineer"
  tags       = { desc = "Infrastructure Engineering Team"}
  policies   = ["arn:aws:iam::aws:policy/AdministratorAccess"]
  principals = {
    "aws" = ["111122223333", "222233334444"]
  }
}
```
