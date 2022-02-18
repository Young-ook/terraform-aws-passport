variable "feature" {
  description = "A configuration to enable feature switch"
  type        = string
  default     = "Disabled"
  validation {
    condition     = var.feature != null && contains(["Disabled", "Enabled", "Suspended"], var.feature)
    error_message = "Allowed values: `Enabled`, `Suspended`."
  }
}

output "feature" {
  value = var.feature
}
