# Application Load Balancer for ECS service.
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.6"

  name               = "${var.prefix}-alb"
  load_balancer_type = "application"
  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets

  security_group_ingress_rules = {
    http_ingress = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_blocks = var.allowed_ips
    }
  }
}

# Target group and listener for ECS service.
resource "aws_lb_target_group" "app" {
  name        = "${var.prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.alb.lb_arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# Attach ECS service to target group
resource "aws_lb_target_group_attachment" "ecs" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = module.ecs.services["app"].tasks[0].eni_id
  port             = 80
  depends_on       = [module.ecs]
}
