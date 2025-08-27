resource "aws_subnet" "chore-bina-public-1a" {
  vpc_id                  = aws_vpc.chore-bina-vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "chore-bina-public-1a"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_subnet" "chore-bina-public-1b" {
  vpc_id                  = aws_vpc.chore-bina-vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "chore-bina-public-1b"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_subnet" "chore-bina-public-1c" {
  vpc_id                  = aws_vpc.chore-bina-vpc.id
  cidr_block              = var.public_subnet_cidrs[2]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "chore-bina-public-1c"
      "kubernetes.io/role/elb" = 1
    }
  )
}