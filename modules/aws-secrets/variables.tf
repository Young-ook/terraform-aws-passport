### secret
variable "secret" {
  description = "Secret string you want to keep safe. It also accepts key-value pairs in JSON."
  validation {
    condition     = var.secret != null && var.secret != "" ? true : false
    error_message = "Secret value is required."
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
