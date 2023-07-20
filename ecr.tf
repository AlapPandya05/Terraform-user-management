resource "aws_ecr_repository" "ecr" {
  name = "user-management-backend-image"
  #   image_tag_mutability = "MUTABLE"

  #   image_scanning_configuration {
  #     scan_on_push = true
  #   }

  provisioner "local-exec" {
    command = <<EOT
      cd /home/alap/user-management-final-task/user-management-backend
      aws ecr get-login-password --region ${var.aws_region[0]} | sudo docker login --username AWS --password-stdin ${aws_ecr_repository.ecr.repository_url}
      docker build -t my-image:latest .
      docker tag my-image:latest ${aws_ecr_repository.ecr.repository_url}:latest
      sudo docker push ${aws_ecr_repository.ecr.repository_url}:latest
    EOT
  }
}


