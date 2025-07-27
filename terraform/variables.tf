variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "suitecrm"
}

variable "environment" {
  description = "Environment name (staging, prod)"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "RDS max allocated storage in GB"
  type        = number
  default     = 100
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "suitecrm"
}

variable "backup_retention_period" {
  description = "Database backup retention period in days"
  type        = number
  default     = 7
}

variable "suitecrm_desired_count" {
  description = "Desired number of SuiteCRM tasks"
  type        = number
  default     = 1
}

variable "chatbot_desired_count" {
  description = "Desired number of Chatbot tasks"
  type        = number
  default     = 1
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default = {
    Project     = "SuiteCRM"
    ManagedBy   = "Terraform"
  }
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository for SuiteCRM"
  type        = string
  default     = ""
}

variable "chatbot_ecr_repository_url" {
  description = "URL of the ECR repository for Chatbot"
  type        = string
  default     = ""
}

variable "openai_api_key" {
  description = "OpenAI API key for chatbot"
  type        = string
  default     = ""
  sensitive   = true
}

variable "suitecrm_client_id" {
  description = "SuiteCRM OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "suitecrm_client_secret" {
  description = "SuiteCRM OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "suitecrm_username" {
  description = "SuiteCRM username for API access"
  type        = string
  default     = ""
  sensitive   = true
}

variable "suitecrm_password" {
  description = "SuiteCRM password for API access"
  type        = string
  default     = ""
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

variable "admin_email" {
  description = "Admin email for SuiteCRM"
  type        = string
  default     = ""
}

variable "db_collation" {
  description = "Database collation"
  type        = string
  default     = "utf8mb4_general_ci"
}

variable "db_charset" {
  description = "Database charset"
  type        = string
  default     = "utf8mb4"
}