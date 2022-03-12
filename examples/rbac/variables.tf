# Variables for providing to module fixture codes

### aws credential
variable "aws_account" {
  description = "The aws account id for the example (e.g. 111123456789)"
}

### network
variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}

### organization
variable "namespace" {
  description = "Namespace to organizae the IAM user"
  default     = null
}

### features
variable "features" {
  description = "A configuration map for feature toggle"
  default     = { "login" = false }
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
