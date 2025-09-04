resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-ecs-cluster"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-cluster"
    }
  )
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name = "${var.project_name}-ecs-logs"
    }
  )
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

module "ecs_services" {
  source = "./services"

  project_name     = var.project_name
  environment      = var.environment
  cluster_name     = aws_ecs_cluster.main.name
  subnet_ids       = var.subnet_ids
  vpc_id           = var.vpc_id
  services         = var.services
  ecr_repositories = var.ecr_repositories
  tags             = var.tags
}