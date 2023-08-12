locals {
  container_definition_name = "task_creation"
}

resource "aws_ecs_task_definition" "task_creation" {
  family = "task_creation"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn = aws_iam_role.task_role.arn
  container_definitions = jsonencode([
    {
      name      = local.container_definition_name
      image     = var.task_creation_service_image
      cpu       = 1024 # 1 vCPU
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.task_creation_service_conainer_port # port on which application inside container is listening
          hostPort      = var.task_creation_service_conainer_port # Port on the machine where the container port will be exposed.
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region" = var.aws_region
          "awslogs-group" = var.cloudwatch_log_group
          "awslogs-stream-prefix" = "task-creation-"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "task_creation" {
  name            = "task_creation_service"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.task_creation.arn
  desired_count   = 2
  deployment_minimum_healthy_percent = 50
  health_check_grace_period_seconds = 60
  launch_type = "FARGATE"
  propagate_tags = "SERVICE"

  load_balancer {
    target_group_arn = aws_lb_target_group.task_creation.arn
    container_name   = local.container_definition_name
    container_port   = var.task_creation_service_conainer_port
  }

 # TODO
 network_configuration{
  subnets = var.private_subnets
  # In: PSQL, Load Balancer SG
  # Out: Everywhere
  security_groups = ["${var.rds_security_group}"]
  assign_public_ip = true
 }

 log_configuration{
  log_driver = "awslogs"
 }
}