### features
variable "enabled" {
  description = "A conditional indicator to create resources"
  default     = true
}

variable "features" {
  description = "A configuration map for feature toggle"
  default     = { "login" = false }
}

### policy
variable "policy_arns" {
  description = "The list of the IAM policy ARNs to attach"
  default     = []
}

variable "password_policy" {
  description = "The password policy for the user"
  default     = { "length" = 16 }
}

### group membership
variable "groups" {
  description = "A list of group names to which the user belongs"
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
