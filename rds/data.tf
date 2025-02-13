data "aws_vpc" "specific_vpc" {
  id = "vpc-0a957f3c148b30050"
}

data "aws_security_group" "lambda_sg" {
  filter {
    name   = "group-name"
    values = ["lambda-security-group"]
  }
}
