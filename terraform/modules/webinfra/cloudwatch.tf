# CloudWatch log group for application logs.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/${var.prefix}/app"
  retention_in_days = 14
  kms_key_id        = var.log_group_kms_key
}

# CloudWatch alarm for high CPU usage of ECS service.
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  alarm_name          = "${var.prefix}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.services["app"].name
  }
}
