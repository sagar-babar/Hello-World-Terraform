resource "aws_ecr_repository" "sagar_repository" {
  name = "sagar/${var.repository_name}"
}
