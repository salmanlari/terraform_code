#s3 ROLE
# resource "aws_iam_role" "s3_role" {
#   name = "s3_test_role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Sid    = ""
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })

#   tags = {
#     tag-key = "tag-value"
#   }
# }

# #S3 POLICY

# resource "aws_iam_policy" "iam_policy" {
#   name        = "iam_test_policy"
#   path        = "/"
#   description = "My test policy"
#   policy = jsonencode(
#     {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Effect": "Allow",
#             "Action": [
#                 "s3:*",
#                 "s3-object-lambda:*"
#             ],
#             "Resource": "*"
#         }
#     ]
# })
# }
# resource "aws_iam_policy_attachment" "iam_attach" {
#   name       = "iam_test-attachment"
#   roles      = [aws_iam_role.s3_role.name]
#   policy_arn = aws_iam_policy.iam_policy.arn
# }
# #s3 INSTANCE PROFILE
# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.s3_role.name
# }

#EC2

resource "aws_instance" "ec2" {
  ami              = var.ami-id
  instance_type    = var.ec2-type
  subnet_id        = var.snet
  security_groups  = [var.sg]
  key_name         = "mumbai_key"
  # iam_instance_profile = aws_iam_instance_profile.test_profile.name 
user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install nginx -y
    sudo apt install php-fpm php-mysql -y
    sudo apt install awscli -y
    sudo apt install mysql-server -y
    cd /var/www/html
    sudo wget http://wordpress.org/latest.tar.gz
    sudo tar -xzvf latest.tar.gz
    sudo chown -R www-data:www-data /var/www/html/
    sudo chmod -R 755 /var/www/html/
EOF

  tags = {
    Name = "dev-ec2"
  }

  // automation for wp-config file

 provisioner "file" {
    content     = data.template_file.phpconfig.rendered
    destination = "/tmp/wp-config.php"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 200 && sudo cp /tmp/wp-config.php /var/www/html/wordpress/wp-config.php",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  //automation for default file

  provisioner "file" {
    content     = data.template_file.nginx.rendered
    destination = "/tmp/default"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 200 && sudo cp /tmp/default /etc/nginx/sites-enabled",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = self.public_ip
      private_key = file(var.ssh_priv_key)
    }
  }
}
data "template_file" "phpconfig" {
  template = file("files/wp-config.php")

  vars = {
    # db_port = aws_db_instance.mysql.port
    db_host = aws_db_instance.wp-rds.address
    db_user = var.username
    db_pass = var.password
    db_name = var.db_name
  }
}
data "template_file" "nginx" {
  template = file("files/default")

}
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
