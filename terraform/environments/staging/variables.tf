variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project     = "SuiteCRM"
    Environment = "staging"
    ManagedBy   = "Terraform"
    Owner       = "QA Team"
  }
}