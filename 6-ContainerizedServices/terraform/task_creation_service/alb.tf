resource "aws_lb" "task_creation" {
  # An internal load balancer routes requests to targets using private IP addresses
  # In our case, this is required since EC2 are in private subnets without any public IP addresses.
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.sg_load_balancer]
  subnets            = var.private_subnets
}

# We will be terminating SSL on the APIG, so we don’t need a secure listener
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.task_creation.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.task_creation.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "task_creation" {
  port        = var.task_creation_service_conainer_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  # health_check {
  #   path = "/actuator/health"
  #   port = var.task_creation_service_conainer_port
  # }
}
