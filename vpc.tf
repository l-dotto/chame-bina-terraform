resource "aws_vpc" "chore-bina-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.tags,
    {
      Name = "chame-bina-vpc"
    }
  )
}
