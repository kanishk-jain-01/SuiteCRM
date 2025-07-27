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
  description = "URL of the chatbot ECR repository"
  type        = string
  default     = ""
}

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

# Health Check Configuration Variables
variable "health_check_interval" {
  description = "Target group health check interval in seconds"
  type        = number
  default     = 60
}

variable "health_check_timeout" {
  description = "Target group health check timeout in seconds"
  type        = number
  default     = 15
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks before marking healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks before marking unhealthy"
  type        = number
  default     = 10
}

variable "health_check_grace_period" {
  description = "ECS service health check grace period in seconds"
  type        = number
  default     = 600
}

variable "deregistration_delay" {
  description = "Target group deregistration delay in seconds"
  type        = number
  default     = 30
}