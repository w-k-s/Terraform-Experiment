resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

  ingress {
    description      = "TLS from Default VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "this" {
  name               = format("%s-AppInstance-LoadBalancer", var.project_name)
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
}

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
  name     = format("%s-AppInstance-TargetGroup", var.project_name)
  port     = 80
  protocol = "HTTP"

  health_check {
    path = "/actuator/health"
    port = 80
  }
}

resource "aws_autoscaling_group" "this" {
  launch_configuration = aws_launch_configuration.this.id
  min_size             = 2
  max_size             = 3
  target_group_arns    = ["${aws_lb_target_group.this.arn}"]
}