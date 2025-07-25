output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.suitecrm.alb_dns_name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.suitecrm.vpc_id
}

output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.suitecrm.ecs_cluster_id
}