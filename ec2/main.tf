resource "aws_instance" "relay_node" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
    Role = "signaturevpn-relay"
  }

  user_data  = var.user_data

  lifecycle {
    ignore_changes = [user_data]
  }
} 
