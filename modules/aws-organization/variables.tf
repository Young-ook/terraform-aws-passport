### organization units
variable "organization_units" {
  description = "A list of organization units"
  default     = []
}

### description
variable "name" {
  description = "The logical name of origanization"
  type        = string
  default     = null
}

### tags
variable "tags" {
  description = "The key-value maps for tagging"
  type        = map(string)
  default     = {}
}
