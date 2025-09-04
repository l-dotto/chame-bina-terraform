resource "aws_subnet" "private-1a" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidrs[0]
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                                    = "${var.project_name}-private-1a",
      "kubernetes.io/role/internal-elb"                       = 1,
      "kubernetes.io/cluster/${var.project_name}-eks-cluster" = "owned"
    }
  )
}

resource "aws_subnet" "private-1b" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidrs[1]
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                                    = "${var.project_name}-private-1b",
      "kubernetes.io/role/internal-elb"                       = 1,
      "kubernetes.io/cluster/${var.project_name}-eks-cluster" = "owned"
    }
  )
}

resource "aws_subnet" "private-1c" {
  vpc_id                  = aws_vpc.eks-vpc.id
  cidr_block              = var.private_subnet_cidrs[2]
  availability_zone       = "${var.aws_region}c"
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                                    = "${var.project_name}-private-1c",
      "kubernetes.io/role/internal-elb"                       = 1,
      "kubernetes.io/cluster/${var.project_name}-eks-cluster" = "owned"
    }
  )
}

resource "aws_route_table_association" "rtb-association-private-1a" {
  subnet_id      = aws_subnet.private-1a.id
  route_table_id = aws_route_table.private-route-table-1a.id
}

resource "aws_route_table_association" "rtb-association-private-1b" {
  subnet_id      = aws_subnet.private-1b.id
  route_table_id = aws_route_table.private-route-table-1b.id
}

resource "aws_route_table_association" "rtb-association-private-1c" {
  subnet_id      = aws_subnet.private-1c.id
  route_table_id = aws_route_table.private-route-table-1c.id
}