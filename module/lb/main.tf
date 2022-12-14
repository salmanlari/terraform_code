#loadbalncer

 resource "aws_lb" "dev-lb" {
  name               = var.name
  internal           = var.alb-type
  load_balancer_type = "application"
  security_groups    = var.sg_groups
  # subnets            = [var.snets1 , var.snets2]
  subnets = var.snets1
  enable_deletion_protection = false

  tags = {
    Environment = "new-dev-lb"
  }
  
}

#target group

resource "aws_lb_target_group" "dev-tg" {
  name        = var.tg-name
  port        = var.port
  protocol    = "HTTP"
  vpc_id      = var.vpc-id
  target_type = var.tg-type
}

# resource "aws_lb_target_group_attachment" "dev-tga" {
# for_each = var.ec2-id
#   target_group_arn    = aws_lb_target_group.dev-tg.arn
#   # target_id          = var.ec2-id
#   target_id           = each.value ["ec2_tg_id"]
#   port                = var.port
# }

resource "aws_lb_listener" "dev-lb-attach" {
  load_balancer_arn = aws_lb.dev-lb.arn
  port              = var.port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tg.arn
  }
}