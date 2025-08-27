resource "aws_subnet" "public-1a" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "${var.project_name}-public-1a"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_subnet" "public-1b" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public_subnet_cidrs[1]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "${var.project_name}-public-1b"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_subnet" "public-1c" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.public_subnet_cidrs[2]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "${var.project_name}-public-1c"
      "kubernetes.io/role/elb" = 1
    }
  )
}

resource "aws_route_table_association" "rtb-association-public-1a" {
  subnet_id      = aws_subnet.public-1a.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "rtb-association-public-1b" {
  subnet_id      = aws_subnet.public-1b.id
  route_table_id = aws_route_table.public-route-table.id
}

resource "aws_route_table_association" "rtb-association-public-1c" {
  subnet_id      = aws_subnet.public-1c.id
  route_table_id = aws_route_table.public-route-table.id
}