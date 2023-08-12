resource "aws_ecr_repository" "this" {
  name                 = format("w-k-s/%s", replace(var.project_name, " ", ""))
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true # destroys repo even if it's not empty (not a good idea for production)

  image_scanning_configuration {
    scan_on_push = true
  }
}