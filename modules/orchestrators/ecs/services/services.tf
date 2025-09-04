resource "aws_ecs_task_definition" "app" {
  for_each = var.services

  family                   = "${var.project_name}-${each.key}-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name  = "${each.key}-container"
      image = lookup(var.ecr_repositories, each.key, "nginx:latest")

      portMappings = [
        {
          containerPort = each.value.port
          hostPort      = each.value.port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.app[each.key].name
          awslogs-region        = data.aws_region.current.id
          awslogs-stream-prefix = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${each.value.port}${each.value.health_check_path} || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      essential = true
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${each.key}-${var.environment}"
      Application = each.key
    }
  )
}

resource "aws_cloudwatch_log_group" "app" {
  for_each = var.services

  name              = "/ecs/${var.project_name}/${each.key}/${var.environment}"
  retention_in_days = 7

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${each.key}-${var.environment}-logs"
      Application = each.key
    }
  )
}

resource "aws_ecs_service" "app" {
  for_each = var.services

  name            = "${var.project_name}-${each.key}-${var.environment}"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.app[each.key].arn
  desired_count   = each.value.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.ecs_service[each.key].id]
    assign_public_ip = true
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${each.key}-${var.environment}"
      Application = each.key
    }
  )
}

data "aws_region" "current" {}