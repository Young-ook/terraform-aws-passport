### security
variable "policy_arns" {
  description = "Additional policies to attach"
  type        = map(list(string))
  default = {
    authenticated   = []
    unauthenticated = []
  }
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
