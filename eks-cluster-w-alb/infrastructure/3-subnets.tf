resource "aws_subnet" "private-eu-west-2a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_block_private_eu_west_2a
  availability_zone = "${var.region}a"

  tags = {
    "Name"                                      = "private-${var.region}a"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private-eu-west-2b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr_block_private_eu_west_2b
  availability_zone = "${var.region}b"

  tags = {
    "Name"                                      = "private-${var.region}b"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-2a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_block_public_eu_west_2a
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-${var.region}a"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public-eu-west-2b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_block_public_eu_west_2b
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "public-${var.region}b"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}