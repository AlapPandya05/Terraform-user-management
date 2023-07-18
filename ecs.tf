resource "aws_ecs_cluster" "ecs" {
  name = "user-management-cluster"
  #   setting {
  #     name  = "containerInsights"
  #     value = "enabled"
  #   }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}


resource "aws_ecs_task_definition" "task-definition-fargate" {
  family                   = "user-management-tf-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "user-management-fargate-container",
    "image": "${var.backend_image_url}",
    "cpu": 2048,
    "memory": 4096,
    "portMappings": [
      {
        "containerPort": 3001,
        "hostPort": 3001,
        "protocol": "tcp"
      }
    ]
  }
]
DEFINITION

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment
  ]

}
