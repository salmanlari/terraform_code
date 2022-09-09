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
   for_each = var.snet1
  ami               = var.ami-id
  instance_type     = var.ec2-type
  #subnet_id        = var.snet
   subnet_id        = each.value ["subnet"]
  security_groups   = [var.sg]
  key_name          = "mumbai_key"
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
     Name = "dev-ec2-${each.value ["name"] }"
  
  }

#   // automation for WP-CONFIG file

#  provisioner "file" {
#     content              = data.template_file.phpconfig.rendered
#     destination          = "/tmp/wp-config.php"

#     connection {
#       type             = "ssh"
#       user             = "ubuntu"
#       host             = self.public_ip
#       private_key      = file(var.ssh_priv_key)
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sleep 200 && sudo cp /tmp/wp-config.php /var/www/html/wordpress/wp-config.php",
#     ]

#     connection {
#       type          = "ssh"
#       user          = "ubuntu"
#       host          = self.public_ip
#       private_key   = file(var.ssh_priv_key)
#     }
#   }

#   //automation for DEFAULT file

#   provisioner "file" {
#     content         = data.template_file.nginx.rendered
#     destination     = "/tmp/default"

#     connection {
#       type          = "ssh"
#       user          = "ubuntu"
#       host          = self.public_ip
#       private_key   = file(var.ssh_priv_key)
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sleep 200 && sudo cp /tmp/default /etc/nginx/sites-enabled",
#     ]

#     connection {
#       type         = "ssh"
#       user         = "ubuntu"
#       host         = self.public_ip
#       private_key  = file(var.ssh_priv_key)
#     }
#   }
# }
# data "template_file" "phpconfig" {
#   template     = file("files/wp-config.php")

#   vars = {
#     # db_port = aws_db_instance.mysql.port
#     db_host    = var.db_instance                       
#     db_user    = var.username
#     db_pass    = var.password
#     db_name    = var.db_name
#   }
# }
# data "template_file" "nginx" {
#   template   = file("files/default")

}

