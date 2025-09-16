resource "aws_ecr_repository" "app_repo" {
  name = "aws-devops-app-repo"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }
}
