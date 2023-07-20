# Creating ECS Cluster

resource "aws_ecs_cluster" "ecs" {
  name = "user-management-cluster"
  # setting {
  #   name  = "containerInsights"
  #   value = "enabled"
  # }
  # setting {
  #   name = "vpc_configuration"
  #   value = jsonencode({
  #     subnets = aws_subnet.private_subnets[*].id
  #   })
  # }
}

# Creating IAM Role for ecs task execution

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

# Attachment of the policy to iam role

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution_role.name
}

# data "aws_ecr_repository" "repo" {
#   name = aws_ecr_repository.ecr.name
# }

# ECS task definition for fargate type service

resource "aws_ecs_task_definition" "task-definition-fargate" {
  family                   = "user-management-tf-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "user-management-fargate-container",
    "image": "${aws_ecr_repository.ecr.repository_url}",
    "cpu": 2048,
    "memory": 4096,
    "command": ["npm", "start"], 
    "workingDirectory": "/app",
    "portMappings": [
      {
        "containerPort": 3001,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
     "secrets": [
        {
          "name": "DB_USERNAME",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_USERNAME::"
        },
        {
          "name": "DB_PASSWORD",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_PASSWORD::"
        },
          {
          "name": "DB_PORT",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_PORT::"
        },
          {
          "name": "DB_HOST",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_HOST::"
        },
          {
          "name": "DB_NAME",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_NAME::"
        }
      ]
  }
]
DEFINITION

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_ecr_repository.ecr
  ]

}

# ECS task definition for EC2 type service

resource "aws_ecs_task_definition" "task-definition-ec2" {
  family                   = "user-management-tf-ec2"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = 2048
  memory                   = 4096
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "user-management-ec2-container",
    "image": "${aws_ecr_repository.ecr.repository_url}",
    "cpu": 2048,
    "memory": 4096,
    "command": ["npm", "start"], 
    "workingDirectory": "/app",
    "portMappings": [
      {
        "containerPort": 3001,
        "hostPort": 0,
        "protocol": "tcp"
      }
    ],
     "secrets": [
        {
          "name": "DB_USERNAME",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_USERNAME::"
        },
        {
          "name": "DB_PASSWORD",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_PASSWORD::"
        },
          {
          "name": "DB_PORT",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_PORT::"
        },
          {
          "name": "DB_HOST",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_HOST::"
        },
          {
          "name": "DB_NAME",
          "valuefrom": "${aws_secretsmanager_secret.credentials.arn}:DB_NAME::"
        }
      ]
  }
]
DEFINITION

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attachment,
    aws_ecr_repository.ecr
  ]

}

# ECS Fargate service 

resource "aws_ecs_service" "ecs_service" {
  name            = "user-management-ecs-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.task-definition-fargate.arn
  desired_count   = 1

  network_configuration {
    subnets          = aws_subnet.private_subnets.*.id
    security_groups  = [aws_security_group.ecs_instance_sg.id]
    assign_public_ip = false
  }
}
