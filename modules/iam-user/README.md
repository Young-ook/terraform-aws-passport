# IAM User
An AWS Identity and Access Management (IAM) [user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users.html) is an entity that you create in AWS to represent the person or application that uses it to interact with AWS. A user in AWS consists of a name and credentials.

## Example
This is simple example of iam-user submodule of passport project.

```hcl
module "user1" {
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = "user1"
  policy_arn = [aws_iam_policy.force-mfa.arn]
  groups     = ["devops-team"]
  tags       = { desc = "DevOps Team"}
}

module "user2" {
  source     = "Young-ook/passport/aws//modules/iam-user"
  name       = "user2"
  policy_arn = [aws_iam_policy.force-mfa.arn]
  groups     = ["developer-team"]
  tags       = { desc = "API Team"}
}
```
