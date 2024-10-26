output "lambda_function_names" {
  value = [for fn in aws_lambda_function.main : fn.function_name]
}