output "arn_map" {
  value = { for fn in aws_lambda_function.main : fn.function_name => fn.arn }
  description = "A mapping of Lambda function names to their ARNs."
}
