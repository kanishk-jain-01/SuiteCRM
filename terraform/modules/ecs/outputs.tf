output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "suitecrm_service_name" {
  description = "Name of the SuiteCRM ECS service"
  value       = aws_ecs_service.suitecrm.name
}

output "chatbot_service_name" {
  description = "Name of the Chatbot ECS service"
  value       = aws_ecs_service.chatbot.name
}

output "suitecrm_task_definition_arn" {
  description = "ARN of the SuiteCRM task definition"
  value       = aws_ecs_task_definition.suitecrm.arn
}

output "chatbot_task_definition_arn" {
  description = "ARN of the Chatbot task definition"
  value       = aws_ecs_task_definition.chatbot.arn
}