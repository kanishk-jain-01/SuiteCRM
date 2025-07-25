output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}

output "efs_file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.main.id
}

output "efs_file_system_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.main.arn
}

output "efs_access_point_uploads_id" {
  description = "ID of the EFS access point for uploads"
  value       = aws_efs_access_point.uploads.id
}

output "efs_access_point_cache_id" {
  description = "ID of the EFS access point for cache"
  value       = aws_efs_access_point.cache.id
}

output "efs_access_point_logs_id" {
  description = "ID of the EFS access point for logs"
  value       = aws_efs_access_point.logs.id
}

output "efs_access_point_chatbot_logs_id" {
  description = "ID of the EFS access point for chatbot logs"
  value       = aws_efs_access_point.chatbot_logs.id
}