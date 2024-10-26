output "lambda_function_name" {
  value = aws_lambda_function.main[count.index].function_name
}