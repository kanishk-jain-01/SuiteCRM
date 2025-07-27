terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket  = "suitecrm-terraform-state-staging"
    key     = "suitecrm/staging/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = var.default_tags
  }
}

module "suitecrm" {
  source = "../../"
  
  # Environment Configuration
  environment = "staging"
  aws_region  = var.aws_region
  
  # VPC Configuration
  vpc_cidr           = "10.1.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  # Database Configuration
  db_allocated_storage    = 50
  db_max_allocated_storage = 200
  db_instance_class       = "db.t3.small"
  backup_retention_period = 7
  
  # ECS Configuration
  suitecrm_desired_count = 1
  chatbot_desired_count  = 1
  
  # ECR Repository URLs
  ecr_repository_url = "787187109626.dkr.ecr.us-east-1.amazonaws.com/suitecrm-staging-suitecrm"
  chatbot_ecr_repository_url = "787187109626.dkr.ecr.us-east-1.amazonaws.com/suitecrm-staging-chatbot"
  
  # Image tag for deployments
  image_tag = var.image_tag
  
  # Secrets (will be set via environment variables)
  openai_api_key = var.openai_api_key
  suitecrm_client_id = var.suitecrm_client_id
  suitecrm_client_secret = var.suitecrm_client_secret
  suitecrm_username = var.suitecrm_username
  suitecrm_password = var.suitecrm_password
  
  # SuiteCRM Installation Configuration
  site_url       = var.site_url
  system_name    = var.system_name
  admin_username = var.admin_username
  admin_password = var.admin_password
  db_charset     = var.db_charset
  db_collation   = var.db_collation
  
  # SSL Configuration (if you have a certificate)
  # domain_name     = "staging.yourdomain.com"
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  
  # Tags
  default_tags = merge(var.default_tags, {
    Environment = "staging"
    CostCenter  = "qa"
  })
}