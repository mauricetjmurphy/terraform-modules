provider "aws" {
  region = var.region
}

##-----------------------------------------------------------------------------
## Random secure password.
##-----------------------------------------------------------------------------

resource "random_password" "db_password" {
  length           = 16                 # Length of the password
  special          = true               # Include special characters
  override_special = "!#$%^&*()-_+=~"   # Allowed special characters for AWS RDS
  upper            = true               # Include uppercase characters
  lower            = true               # Include lowercase characters
  numeric          = true               # Include numbers
}

##-----------------------------------------------------------------------------
## Adds secrets to secret manager.
##-----------------------------------------------------------------------------

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = var.secret_name
  description = "Credentials for RDS MySQL instance"
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id

  secret_string = jsonencode({
    db_name       = aws_db_instance.mysql.db_name
    username      = aws_db_instance.mysql.username
    password      = random_password.db_password.result
    host          = aws_db_instance.mysql.endpoint
    port          = aws_db_instance.mysql.port
    connection_url = "mysql://${aws_db_instance.mysql.username}:${random_password.db_password.result}@${aws_db_instance.mysql.endpoint}:${aws_db_instance.mysql.port}/${aws_db_instance.mysql.db_name}"
  })

  # Ensure the secret is created after the RDS instance
  depends_on = [aws_db_instance.mysql]
}

##-----------------------------------------------------------------------------
## IAM role for RDS.
##-----------------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring_role" {
  name = "rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring_policy" {
  role       = aws_iam_role.rds_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

##-----------------------------------------------------------------------------
## RDS subnets.
##-----------------------------------------------------------------------------

resource "aws_subnet" "rds_subnets" {
  count = length(var.azs)

  vpc_id                  = var.vpc_id
  cidr_block              = cidrsubnet(var.base_cidr, 4, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "RDS Subnet - ${var.environment}-${count.index}"
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.environment}-rds-subnet-group"
  description = "Subnet group for RDS instance in ${var.environment} environment"
  subnet_ids  = aws_subnet.rds_subnets[*].id 

  tags = {
    Name        = "RDS Subnet Group - ${var.environment}"
    Environment = var.environment
  }
}

##-----------------------------------------------------------------------------
## RDS security group.
##-----------------------------------------------------------------------------
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow MySQL access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Update as needed
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_db_instance" "mysql" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  password             = random_password.db_password.result
  publicly_accessible  = var.publicly_accessible
  skip_final_snapshot  = var.skip_final_snapshot

  # Minimal storage and backup retention
  backup_retention_period = var.backup_retention_period
  storage_type            = var.storage_type
  storage_encrypted       = var.storage_encrypted

 # Use the new subnet group
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name

  # Security Groups
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = var.tags
}
