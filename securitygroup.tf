resource "aws_security_group" "ecs_instance_sg" {
  name        = "my-ecs-instance-sg"
  description = "Security group for ECS instances"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow all incoming traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all_traffic"
  }

}
