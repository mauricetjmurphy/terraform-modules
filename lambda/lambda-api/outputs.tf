output "lambda_arns" {
  value       = { for key, lambda_instance in module.lambda : key => lambda_instance.arn_map }
  description = "A mapping of Lambda function names to their ARNs."
}
