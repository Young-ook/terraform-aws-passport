# Variables for providing to module fixture codes

### aws credential
variable "aws_account" {
  description = "The aws account id for the example (e.g. 857026751867)"
}

### network
variable "aws_region" {
  description = "The region where AWS operations will take place. Examples are us-east-1, ap-northeast-2, etc."
  default     = "us-east-1"
}

### organization
variable "namespace" {
  description = "Namespace to organizae the IAM user"
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
