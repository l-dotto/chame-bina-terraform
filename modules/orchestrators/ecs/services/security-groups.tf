resource "aws_security_group" "ecs_service" {
  for_each = var.services

  name_prefix = "${var.project_name}-${each.key}-${var.environment}-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = each.value.port
    to_port     = each.value.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${each.key}-${var.environment}-sg"
      Application = each.key
    }
  )
}