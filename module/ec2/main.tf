resource "aws_instance" "ec2" {
  ami              = var.ami-id
  instance_type    = var.ec2-type
  subnet_id        = var.snet
  security_groups  = [var.sg]
key_name = "mumbai_key"
user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install nginx -y 
    
EOF

  tags = {
    Name = "dev-ec2"
  }
}






