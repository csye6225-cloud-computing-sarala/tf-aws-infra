# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "app-asg"
  max_size            = 5
  min_size            = 3
  desired_capacity    = 3
  default_cooldown    = 60
  vpc_zone_identifier = aws_subnet.public.*.id
  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }
  target_group_arns         = [aws_lb_target_group.app_tg.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  metrics_granularity       = "1Minute"
  enabled_metrics = ["GroupInServiceInstances", "GroupTotalInstances", "GroupDesiredCapacity",
    "GroupInServiceCapacity", "GroupPendingCapacity", "GroupStandbyCapacity",
  "GroupTerminatingCapacity", "GroupTotalCapacity"]

  tag {
    key                 = "Name"
    value               = "AppInstance"
    propagate_at_launch = true
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 5
    interval            = var.health_check_interval
    path                = "/healthz"
    matcher             = "200"
  }
}

# Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "AppLoadBalancer"
  }
}

# Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up-policy"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  threshold           = var.cpu_high_threshold
  alarm_description   = "Scale up when CPU > 5%"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  metric_query {
    id          = "avg_cpu"
    return_data = true

    metric {
      metric_name = var.metric_name
      namespace   = "AWS/EC2"
      period      = 60
      stat        = "Average"
      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.app_asg.name
      }
    }
  }
}



# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down-policy"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_low_threshold
  alarm_description   = "Scale down when CPU < 3%"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }
}
