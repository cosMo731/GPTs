resource "aws_ecs_task_definition" "app" {
  family                   = "${var.prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = "arn:aws:iam::123456789012:role/ecsExecutionRole"
  task_role_arn      = "arn:aws:iam::123456789012:role/ecsTaskRole"

  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${var.ecr_repo}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.prefix}"
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.app.arn
}
