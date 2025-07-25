terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  # Uncomment and configure for remote state
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "suitecrm/staging/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
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
  suitecrm_desired_count = 2
  chatbot_desired_count  = 1
  
  # SSL Configuration (if you have a certificate)
  # domain_name     = "staging.yourdomain.com"
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  
  # Tags
  default_tags = merge(var.default_tags, {
    Environment = "staging"
    CostCenter  = "qa"
  })
}