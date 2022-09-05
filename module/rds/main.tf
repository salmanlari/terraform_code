
#RDS INSTANCE

resource "aws_db_instance" "wp-rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  db_name              = var.db_name
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true
  availability_zone    = "ap-south-1a"
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [var.rds-sg]
}





resource "aws_db_subnet_group" "db_group" {
  name       = "main"
  subnet_ids = [var.pubsnet1, var.pubsnet2]

  tags = {
    Name = "DB _subnet_ group"
  }
}