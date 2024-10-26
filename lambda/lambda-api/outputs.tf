output "arns" {
  value = [for fn in aws_lambda_function.main : fn.arn]  
}