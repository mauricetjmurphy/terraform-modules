provider "aws" {
  region = var.region
}

resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description
}


