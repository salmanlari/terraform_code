#s3 ROLE
resource "aws_iam_role" "s3_role" {
  name = "s3_test_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

#S3 POLICY

resource "aws_iam_policy" "iam_policy" {
  name        = "iam_test_policy"
  path        = "/"
  description = "My test policy"
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        }
    ]
})
}
resource "aws_iam_policy_attachment" "iam_attach" {
  name       = "iam_test-attachment"
  roles      = [aws_iam_role.s3_role.name]
  policy_arn = aws_iam_policy.iam_policy.arn
}
#s3 INSTANCE PROFILE
resource "aws_iam_instance_profile" "test_profile" {
  name = "test_profile"
  role = aws_iam_role.s3_role.name
}

#EC2

resource "aws_instance" "ec2" {
  ami              = var.ami-id
  instance_type    = var.ec2-type
  subnet_id        = var.snet
  security_groups  = [var.sg]
  key_name         = "mumbai_key"
user_data = <<EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo apt install php-fpm php-mysql -y
    sudo apt install awscli -y
    sudo apt install mysql-server -y
    sudo cd /var/www/html
    sudo wget http://wordpress.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz
    sudo mv -f wordpress/* /var/www/html
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod -R 755 /var/www/html/
    sudo aws s3 cp s3://endpoint11/wp-config.php /var/www/html/wordpress
    sudo aws s3 cp s3://endpoint11/default /etc/nginx/sites-enabled
EOF

  tags = {
    Name = "dev-ec2"
  }
}

#RDS INSTANCE

resource "aws_db_instance" "wp-rds" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0.28"
  instance_class       = "db.t3.micro"
  name                 = "db_name"
  username             = "admin"
  password             = "qwerty123"
  skip_final_snapshot  = true
  availability_zone    = "ap-south-1a"
  db_subnet_group_name = aws_db_subnet_group.db_group.name
}



resource "aws_db_subnet_group" "db_group" {
  name       = "main"
  subnet_ids = [var.pubsnet1, var.pubsnet2]

  tags = {
    Name = "DB _subnet_ group"
  }
}
