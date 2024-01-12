### record
variable "record_config" {
  description = "awsconfig recorder configuration"
  default     = {}
}

### description
variable "name" {
  description = "The logical name of user"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
