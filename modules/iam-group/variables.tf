### target roles
variable "target_roles" {
  description = "A list of full arn of iam roles to allow assuming"
  default     = []
}

### policy
variable "policy_arns" {
  description = "The list of full IAM policy ARNs to attach"
  default     = []
}

### organization
variable "namespace" {
  description = "Namespace to organizae the IAM user"
  default     = null
}

### description
variable "name" {
  description = "The logical name of user"
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
