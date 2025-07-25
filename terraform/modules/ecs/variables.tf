variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "ecs_security_group_id" {
  description = "ID of the ECS security group"
  type        = string
}

variable "db_host" {
  description = "Database host"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_secret_arn" {
  description = "ARN of the database secret"
  type        = string
  default     = ""
}

variable "efs_file_system_id" {
  description = "ID of the EFS file system"
  type        = string
}

variable "efs_access_point_uploads_id" {
  description = "ID of the EFS access point for uploads"
  type        = string
  default     = ""
}

variable "efs_access_point_cache_id" {
  description = "ID of the EFS access point for cache"
  type        = string
  default     = ""
}

variable "efs_access_point_logs_id" {
  description = "ID of the EFS access point for logs"
  type        = string
  default     = ""
}

variable "efs_access_point_chatbot_logs_id" {
  description = "ID of the EFS access point for chatbot logs"
  type        = string
  default     = ""
}

variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
  default     = ""
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

variable "ecr_repository_url" {
  description = "URL of the ECR repository for SuiteCRM"
  type        = string
  default     = "suitecrm:latest"
}

variable "chatbot_ecr_repository_url" {
  description = "URL of the ECR repository for Chatbot"
  type        = string
  default     = "suitecrm-chatbot:latest"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}