### event source
variable "event_config" {
  description = "Event rules configuration"
  default     = {}
}

### network
variable "vpc_config" {
  description = "VPC configuration for function"
  default     = {}
}

### compute
variable "lambda_config" {
  description = "Lambda function configuration"
  default     = {}
}

### log
variable "log_config" {
  description = "Log configuration for function"
  default     = {}
}

### tracing
variable "tracing_config" {
  description = "AWS X-ray tracing configuration for function"
  default     = {}
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
