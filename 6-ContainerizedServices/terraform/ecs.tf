resource "aws_ecs_cluster" "this" {
  name = format("%s-Cluster", var.project_id)
}


