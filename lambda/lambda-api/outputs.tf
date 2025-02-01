output "arn_map" {
  value = { for key, fn in aws_lambda_function.main : key => fn.arn }
  description = "A mapping of Lambda function names to their ARNs."
}
