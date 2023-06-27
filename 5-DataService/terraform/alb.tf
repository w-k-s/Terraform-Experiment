resource "aws_lb" "this" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = data.aws_subnets.private_subnets.ids
}

# We will be terminating SSL on the APIG, so we don’t need a secure listener
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "this" {
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.this.id
  target_type = "instance"

  health_check {
    path = "/actuator/health"
    port = 80
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = format("%s-autoscaling-group", var.project_id)
  launch_configuration = aws_launch_configuration.this.id
  min_size             = 2
  max_size             = 3
  target_group_arns    = ["${aws_lb_target_group.this.arn}"]
  vpc_zone_identifier  = data.aws_subnets.private_subnets.ids

  tag {
    key                 = "Name"
    value               = format("%s-app-instance", var.project_id)
    propagate_at_launch = true
  }
}