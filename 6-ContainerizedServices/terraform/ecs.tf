resource "aws_ecs_cluster" "this" {
  name = "${var.project_id}-Cluster"
}


