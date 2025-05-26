data "aws_caller_identity" "current" {}

resource "aws_secretsmanager_secret" "this" {
  name                    = var.name
  description             = var.description
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode(var.secret_values)
}

resource "aws_secretsmanager_resource_policy" "this" {
  count      = var.create_policy ? 1 : 0
  secret_arn = aws_secretsmanager_secret.this.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for role_name in var.reader_role_names : {
        Sid       = "AllowReadAccess${role_name}"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${role_name}"
        }
        Action    = "secretsmanager:GetSecretValue"
        Resource  = aws_secretsmanager_secret.this.arn
      }
    ]
  })
}
