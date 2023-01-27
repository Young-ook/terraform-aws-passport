# Variables for providing to module fixture codes

### aws credential
variable "aws_account" {
  description = "The aws account id (e.g. 111123456789)"
  default     = null
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
  description = "Configuration map for feature toggle"
  default     = { "login" = false }
}

### notification
variable "slack" {
  description = "Configurations for Slack notification"
  sensitive   = true
  default = {
    webhook_url = ""
    channel     = ""
  }
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
