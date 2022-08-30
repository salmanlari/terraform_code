# auto-scalling
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.20220805.0-x86_64-gp2"]
  }

}

resource "aws_launch_configuration" "dev-conf" {
  # name          = "${var.app_name}-${env}-lc"
  name_prefix = "lc"
  image_id      = var.ami-id
  instance_type = var.ec2-instance-type
  security_groups = var.sg_groups
  key_name = var.key-name
    lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "asg-policy" {
  name                   = "asg-policy"
  scaling_adjustment     = 4
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

resource "aws_autoscaling_group" "asg" {
  #availability_zones        = data.aws_availability_zones.available.names
  vpc_zone_identifier = var.pub-snet
  name                      = "app-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.dev-conf.id
  target_group_arns = [var.tg-arn]
}