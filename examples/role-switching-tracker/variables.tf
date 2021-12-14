# Variables for providing to module fixture codes

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

### notification
variable "slack_webhook_url" {
  description = "Slack webhook url to send message"
  sensitive   = true
}

variable "slack_channel" {
  description = "Slack channel ID where you want to send message"
  sensitive   = true
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