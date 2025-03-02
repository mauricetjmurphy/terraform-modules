output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = coalesce(
    length(aws_dynamodb_table.this) > 0 ? aws_dynamodb_table.this[0].arn : null,
    length(aws_dynamodb_table.autoscaled) > 0 ? aws_dynamodb_table.autoscaled[0].arn : null,
    length(aws_dynamodb_table.autoscaled_gsi_ignore) > 0 ? aws_dynamodb_table.autoscaled_gsi_ignore[0].arn : null
  )
}

output "dynamodb_table_id" {
  description = "ID of the DynamoDB table"
  value       = coalesce(
    length(aws_dynamodb_table.this) > 0 ? aws_dynamodb_table.this[0].id : null,
    length(aws_dynamodb_table.autoscaled) > 0 ? aws_dynamodb_table.autoscaled[0].id : null,
    length(aws_dynamodb_table.autoscaled_gsi_ignore) > 0 ? aws_dynamodb_table.autoscaled_gsi_ignore[0].id : null
  )
}

output "dynamodb_table_stream_arn" {
  description = "The ARN of the Table Stream. Only available when var.stream_enabled is true"
  value       = var.stream_enabled ? coalesce(
    length(aws_dynamodb_table.this) > 0 ? aws_dynamodb_table.this[0].stream_arn : null,
    length(aws_dynamodb_table.autoscaled) > 0 ? aws_dynamodb_table.autoscaled[0].stream_arn : null,
    length(aws_dynamodb_table.autoscaled_gsi_ignore) > 0 ? aws_dynamodb_table.autoscaled_gsi_ignore[0].stream_arn : null
  ) : null
}

output "dynamodb_table_stream_label" {
  description = "A timestamp, in ISO 8601 format of the Table Stream. Only available when var.stream_enabled is true"
  value       = var.stream_enabled ? coalesce(
    length(aws_dynamodb_table.this) > 0 ? aws_dynamodb_table.this[0].stream_label : null,
    length(aws_dynamodb_table.autoscaled) > 0 ? aws_dynamodb_table.autoscaled[0].stream_label : null,
    length(aws_dynamodb_table.autoscaled_gsi_ignore) > 0 ? aws_dynamodb_table.autoscaled_gsi_ignore[0].stream_label : null
  ) : null
}
