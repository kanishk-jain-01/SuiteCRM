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
  #   key            = "suitecrm/dev/terraform.tfstate"
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
  environment = "dev"
  aws_region  = var.aws_region
  
  # VPC Configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  # Database Configuration
  db_allocated_storage    = 20
  db_max_allocated_storage = 50
  db_instance_class       = "db.t3.micro"
  backup_retention_period = 3
  
  # ECS Configuration
  suitecrm_desired_count = 1
  chatbot_desired_count  = 1
  
  # Tags
  default_tags = merge(var.default_tags, {
    Environment = "dev"
    CostCenter  = "development"
  })
}