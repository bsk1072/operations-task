resource "aws_db_subnet_group" "development" {
  name       = "main"
  subnet_ids = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

resource "aws_db_instance" "development" {
  identifier              = "development"
  db_name                 = "ratesdb"
  username                = var.rds_username
  password                = var.rds_password
  port                    = "5432"
  engine                  = "postgres"
  engine_version          = "12.3"
  instance_class          = var.rds_instance_class
  allocated_storage       = "20"
  storage_encrypted       = false
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.development.name
  multi_az                = false
  storage_type            = "gp2"
  publicly_accessible     = true
  backup_retention_period = 7
  skip_final_snapshot     = true
}
