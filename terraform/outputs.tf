output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.ecs.alb_zone_id
}

output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.ecs_cluster_id
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = module.storage.efs_file_system_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "suitecrm_ecr_repository_url" {
  description = "URL of the SuiteCRM ECR repository"
  value       = module.ecr.suitecrm_repository_url
}

output "chatbot_ecr_repository_url" {
  description = "URL of the Chatbot ECR repository"
  value       = module.ecr.chatbot_repository_url
}