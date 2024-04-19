# 1- Create EFS that Pod of the cluster will use
resource "aws_efs_file_system" "efs" {
  creation_token   = "data-efs"
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_60_DAYS"
  }

  tags = {
    project     = var.project
    sub-project = var.sub-project
  }
}

# 2- Set security groups for EFS

resource "aws_security_group" "efs" {
  name        = "efs-sg"
  description = "Allow inbound efs traffic from private Kubernetes Subnets where nodes are placed"
  vpc_id      = aws_vpc.main.id

  ingress {
    cidr_blocks = [var.cidr_block_private_eu_west_2a, var.cidr_block_private_eu_west_2b]
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = [var.cidr_block_private_eu_west_2a, var.cidr_block_private_eu_west_2b]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  depends_on = [
    aws_vpc.main
  ]
}

# 3- Set EFS mount target
resource "aws_efs_mount_target" "efs_mount_target-eu-west-2a" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-eu-west-2a.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "efs_mount_target-eu-west-2b" {
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       = aws_subnet.private-eu-west-2b.id
  security_groups = [aws_security_group.efs.id]
}