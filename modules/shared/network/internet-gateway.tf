resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-igw"
    }
  )
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-public-rtb"
    }
  )
}