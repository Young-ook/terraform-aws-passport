
terraform {
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "The aws region to deploy"
  type        = string
  default     = "us-east-1"
}
