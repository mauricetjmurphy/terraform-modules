output "rds_instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.mysql.id
}

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.mysql.endpoint
}

output "rds_arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.mysql.arn
}

output "rds_connection_url" {
  description = "Connection URL for the RDS instance"
  value       = "mysql://${aws_db_instance.mysql.username}:${random_password.db_password.result}@${aws_db_instance.mysql.endpoint}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}"
  sensitive   = true
}

output "rds_sg_id" {
  description = "Security Group ID for the RDS instance"
  value       = aws_security_group.rds_sg.id
}


