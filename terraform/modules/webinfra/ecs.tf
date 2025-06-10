# ECS cluster and Fargate service with ALB.
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.7"

  cluster_name = "${var.prefix}-cluster"

  fargate_capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  services = {
    app = {
      cpu                    = 256
      memory                 = 512
      desired_count          = 1
      assign_public_ip       = false
      task_exec_iam_role_arn = var.ecs_execution_role_arn
      task_iam_role_arn      = var.ecs_task_role_arn
      container_definitions = [
        {
          name  = "app"
          image = "${module.ecr.repository_url}:latest"
          port_mappings = [
            {
              container_port = 80
              protocol       = "tcp"
            }
          ]
          environment = var.app_environment
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = aws_cloudwatch_log_group.app.name
              awslogs-region        = var.region
              awslogs-stream-prefix = "ecs"
            }
          }
        }
      ]
      subnet_ids = module.vpc.private_subnets
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = 80
          to_port                  = 80
          protocol                 = "tcp"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
}
