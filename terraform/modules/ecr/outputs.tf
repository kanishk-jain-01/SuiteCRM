output "suitecrm_repository_url" {
  description = "URL of the SuiteCRM ECR repository"
  value       = aws_ecr_repository.suitecrm.repository_url
}

output "chatbot_repository_url" {
  description = "URL of the Chatbot ECR repository"
  value       = aws_ecr_repository.chatbot.repository_url
}

output "suitecrm_repository_arn" {
  description = "ARN of the SuiteCRM ECR repository"
  value       = aws_ecr_repository.suitecrm.arn
}

output "chatbot_repository_arn" {
  description = "ARN of the Chatbot ECR repository"
  value       = aws_ecr_repository.chatbot.arn
}