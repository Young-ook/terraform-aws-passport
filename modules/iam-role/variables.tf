### features
variable "enabled" {
  description = "A conditional indicator to create resources"
  default     = true
}

### trusted accounts 
### To allow assuming from badge users, the AWS account Id of badge account must be included in this list
variable "trusted_roles" {
  description = "The list of aws account IDs or role ARNs to allow them to assume roles"
  default     = []
}

### policy
variable "policies" {
  description = "The list of full IAM policy ARNs to attach this role"
  default     = []
}

variable "session_duration" {
  description = "A value for maximum time of session duration in seconds (default 1h)"
  default     = "3600"
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
