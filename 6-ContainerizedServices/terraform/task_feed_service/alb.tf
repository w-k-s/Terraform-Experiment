resource "aws_lb" "task_feed" {
  # An internet-facing load balancer routes requests from clients to targets over the internet. 
  # An internal load balancer routes requests to targets using private IP addresses.
  # In our case, this is required since our ecs service has a private ip.
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.sg_load_balancer]
  subnets            = var.private_subnets
}

# We will be terminating SSL on the APIG, so we don’t need a secure listener
resource "aws_lb_listener" "task_feed" {
  load_balancer_arn = aws_lb.task_feed.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.task_feed.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "task_feed" {
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path = "/actuator/health"
  }
}
