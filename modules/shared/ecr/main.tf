resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.repository_names)

  name                 = "${var.project_name}-${each.value}"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-${each.value}"
    }
  )
}

resource "aws_ecr_lifecycle_policy" "repositories" {
  for_each = toset(var.repository_names)

  repository = aws_ecr_repository.repositories[each.value].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 20 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  depends_on = [aws_ecr_repository.repositories]
}