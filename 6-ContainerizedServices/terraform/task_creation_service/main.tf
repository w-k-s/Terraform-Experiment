locals {
  cpu                       = 1024 # 1 vCPU 
  memory                    = 2048 # See: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  container_definition_name = "task_creation"
}

resource "aws_ecs_task_definition" "task_creation" {
  family                   = local.container_definition_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = local.container_definition_name
      image     = var.task_creation_service_image
      cpu       = local.cpu
      memory    = local.memory
      essential = true
      portMappings = [
        {
          containerPort = var.task_creation_service_conainer_port # port on which application inside container is listening
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.aws_region
          "awslogs-group"         = var.cloudwatch_log_group
          "awslogs-stream-prefix" = "task-creation-"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "task_creation" {
  name                               = "task_creation_service"
  cluster                            = var.cluster_arn
  task_definition                    = aws_ecs_task_definition.task_creation.arn
  desired_count                      = 1 # Update to 2
  deployment_minimum_healthy_percent = 0 # Update to 50
  health_check_grace_period_seconds  = 60
  launch_type                        = "FARGATE"
  propagate_tags                     = "SERVICE"

  load_balancer {
    target_group_arn = aws_lb_target_group.task_creation.arn
    container_name   = local.container_definition_name
    container_port   = var.task_creation_service_conainer_port
  }

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = ["${var.sg_app}"]
    assign_public_ip = false
  }

}
