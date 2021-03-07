### organization
variable "aws_account" {
  description = "The aws account id to apply on"
}

variable "namespace" {
  description = "Namespace to organizae the users and groups"
  default     = null
}

### description
variable "name" {
  description = "The logical name of the module instance"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
