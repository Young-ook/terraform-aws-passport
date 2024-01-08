### input variables

### features
variable "analyzer" {
  description = "A configuration for iam access analyzer"
  default     = {}
  validation {
    condition     = var.analyzer != null
    error_message = "Make sure to define valid iam access analyzer configuration."
  }
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
