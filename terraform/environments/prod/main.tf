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
  #   key            = "suitecrm/prod/terraform.tfstate"
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
  environment = "prod"
  aws_region  = var.aws_region
  
  # VPC Configuration
  vpc_cidr           = "10.2.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  # Database Configuration
  db_allocated_storage    = 100
  db_max_allocated_storage = 1000
  db_instance_class       = "db.t3.medium"
  backup_retention_period = 30
  
  # ECS Configuration
  suitecrm_desired_count = 3
  chatbot_desired_count  = 2
  
  # SSL Configuration (configure with your actual domain and certificate)
  # domain_name     = "yourdomain.com"
  # certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"
  
  # Tags
  default_tags = merge(var.default_tags, {
    Environment = "prod"
    CostCenter  = "production"
    Compliance  = "required"
  })
}