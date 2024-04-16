resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "project"     = var.project
    "sub-project" = var.sub-project
    "Name"        = "igw"
  }
}