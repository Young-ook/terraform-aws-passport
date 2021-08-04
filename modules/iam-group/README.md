# IAM Group
An IAM [user group](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_groups.html) is a collection of IAM users. User groups let you specify permissions for multiple users, which can make it easier to manage the permissions for those users. For example, you could have a user group called Admins and give that user group the types of permissions that administrators typically need. Any user in that user group automatically has the permissions that are assigned to the user group. If a new user joins your organization and needs administrator privileges, you can assign the appropriate permissions by adding the user to that user group. Similarly, if a person changes jobs in your organization, instead of editing that user's permissions, you can remove him or her from the old user groups and add him or her to the appropriate new user groups.

## Example
This is simple example of iam-group submodule of passport project.

```hcl
module "badge" {
  source    = "Young-ook/passport/aws//modules/iam-group"
  name      = "badge"
  tags      = { desc = "Badge for all"}
  policies = [
    aws_iam_policy.force-mfa.arn,
    aws_iam_policy.creds-self.arn,
  ]
}
```
