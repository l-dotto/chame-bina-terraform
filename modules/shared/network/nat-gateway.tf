resource "aws_eip" "eip-1a" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-1a"
    }
  )
}

resource "aws_eip" "eip-1b" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-1b"
    }
  )
}

resource "aws_eip" "eip-1c" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-eip-1c"
    }
  )
}

resource "aws_nat_gateway" "nat-gateway-1a" {
  allocation_id = aws_eip.eip-1a.id
  subnet_id     = aws_subnet.public-1a.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-1a"
    }
  )

  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_nat_gateway" "nat-gateway-1b" {
  allocation_id = aws_eip.eip-1b.id
  subnet_id     = aws_subnet.public-1b.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-1b"
    }
  )

  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_nat_gateway" "nat-gateway-1c" {
  allocation_id = aws_eip.eip-1c.id
  subnet_id     = aws_subnet.public-1c.id

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ngw-1c"
    }
  )

  depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_route_table" "private-route-table-1a" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-1a.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rtb-1a"
    }
  )
}

resource "aws_route_table" "private-route-table-1b" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-1b.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rtb-1b"
    }
  )
}

resource "aws_route_table" "private-route-table-1c" {
  vpc_id = aws_vpc.eks-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway-1c.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-private-rtb-1c"
    }
  )
}