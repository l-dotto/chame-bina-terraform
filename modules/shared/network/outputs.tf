output "subnet-public-1a" {
  value = aws_subnet.public-1a.id
}

output "subnet-public-1b" {
  value = aws_subnet.public-1b.id
}

output "subnet-public-1c" {
  value = aws_subnet.public-1c.id
}

output "subnet-private-1a" {
  value = aws_subnet.private-1a.id
}

output "subnet-private-1b" {
  value = aws_subnet.private-1b.id
}

output "subnet-private-1c" {
  value = aws_subnet.private-1c.id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.eks-vpc.id
}