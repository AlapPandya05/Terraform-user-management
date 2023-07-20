resource "aws_secretsmanager_secret" "credentials" {
  name = "mydb-credentials"
}

resource "aws_secretsmanager_secret_version" "credentials" {
  secret_id = aws_secretsmanager_secret.credentials.id
  secret_string = jsonencode({
    "db_username" : "alap",
    "db_password" : random_password.generate_password.result
  })
}

resource "random_password" "generate_password" {
  length           = 20
  special          = true
  override_special = ""
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-rds-subnet-group"
  subnet_ids = aws_subnet.database_subnets[*].id
}

resource "aws_db_instance" "database" {

  allocated_storage    = 10
  db_name              = "mydb"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  identifier           = "user-management-db"
  username             = "alap"
  password             = random_password.generate_password.result
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  depends_on           = [random_password.generate_password, aws_secretsmanager_secret.credentials, aws_secretsmanager_secret_version.credentials]

  tags = {
    Name = "User-management-db"
  }
}
