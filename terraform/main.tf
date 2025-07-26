locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  common_tags = merge(var.default_tags, {
    Environment = var.environment
  })
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  name_prefix        = local.name_prefix
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  
  tags = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"
  
  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  
  tags = local.common_tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  name_prefix                = local.name_prefix
  vpc_id                    = module.vpc.vpc_id
  private_subnet_ids        = module.vpc.private_subnet_ids
  database_security_group_id = module.security.database_security_group_id
  
  allocated_storage         = var.db_allocated_storage
  max_allocated_storage     = var.db_max_allocated_storage
  instance_class           = var.db_instance_class
  username                 = var.db_username
  backup_retention_period  = var.backup_retention_period
  multi_az                 = var.environment == "prod"
  
  tags = local.common_tags
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"
  
  name_prefix            = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  alb_security_group_id = module.security.alb_security_group_id
  ecs_security_group_id = module.security.ecs_security_group_id
  
  # Database connection
  db_host     = module.rds.db_endpoint
  db_name     = module.rds.db_name
  db_username = module.rds.db_username
  db_password = module.rds.db_password
  
  # EFS file system
  efs_file_system_id = module.storage.efs_file_system_id
  efs_access_point_uploads_id = module.storage.efs_access_point_uploads_id
  efs_access_point_cache_id = module.storage.efs_access_point_cache_id
  efs_access_point_logs_id = module.storage.efs_access_point_logs_id
  efs_access_point_chatbot_logs_id = module.storage.efs_access_point_chatbot_logs_id
  
  # S3 bucket
  s3_bucket_arn = module.storage.s3_bucket_arn
  
  # Database secret
  db_secret_arn = module.rds.db_secret_arn
  
  # ECR repositories - use provided URLs or fallback to module output
  ecr_repository_url = var.ecr_repository_url != "" ? var.ecr_repository_url : module.ecr.suitecrm_repository_url
  chatbot_ecr_repository_url = var.chatbot_ecr_repository_url != "" ? var.chatbot_ecr_repository_url : module.ecr.chatbot_repository_url
  
  # Task counts
  suitecrm_desired_count = var.suitecrm_desired_count
  chatbot_desired_count  = var.chatbot_desired_count
  
  # SSL
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  
  # Secrets
  openai_api_key = var.openai_api_key
  suitecrm_client_id = var.suitecrm_client_id
  suitecrm_client_secret = var.suitecrm_client_secret
  suitecrm_username = var.suitecrm_username
  suitecrm_password = var.suitecrm_password
  
  tags = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  
  name_prefix            = local.name_prefix
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  efs_security_group_id = module.security.efs_security_group_id
  
  tags = local.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"
  
  name_prefix = local.name_prefix
  
  tags = local.common_tags
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"
  
  name_prefix    = local.name_prefix
  ecs_cluster_id = module.ecs.ecs_cluster_id
  
  tags = local.common_tags
}