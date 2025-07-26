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

variable "openai_api_key" {
  description = "OpenAI API key for chatbot"
  type        = string
  sensitive   = true
}

variable "suitecrm_client_id" {
  description = "SuiteCRM OAuth client ID"
  type        = string
  sensitive   = true
}

variable "suitecrm_client_secret" {
  description = "SuiteCRM OAuth client secret"
  type        = string
  sensitive   = true
}

variable "suitecrm_username" {
  description = "SuiteCRM username for API access"
  type        = string
  sensitive   = true
}

variable "suitecrm_password" {
  description = "SuiteCRM password for API access"
  type        = string
  sensitive   = true
}

# SuiteCRM Installation Configuration
variable "site_url" {
  description = "Site URL for SuiteCRM (will use ALB DNS if empty)"
  type        = string
  default     = ""
}

variable "system_name" {
  description = "System name for SuiteCRM"
  type        = string
  default     = "SuiteCRM"
}

variable "admin_username" {
  description = "Admin username for SuiteCRM"
  type        = string
  default     = "admin"
}

variable "admin_password" {
  description = "Admin password for SuiteCRM"
  type        = string
  default     = ""
  sensitive   = true
}

variable "db_charset" {
  description = "Database charset"
  type        = string
  default     = "utf8mb4"
}

variable "db_collation" {
  description = "Database collation"
  type        = string
  default     = "utf8mb4_general_ci"
}