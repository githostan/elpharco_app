
# aws_lb for the webtier frontend servers
resource "aws_lb" "elpharco-webtier-alb" {
  name               = "elpharco-webtier-alb"
  internal           = false  # The alb is Internet-facing and not internal
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.elpharco-webtier-alb-sg.id] 
  subnets            = [aws_subnet.elpharco-webtier-public-snet-01.id, aws_subnet.elpharco-webtier-public-snet-02.id]  # public subnet IDs

  tags = {
    Name = "webtier-alb"
  }
}

# Frontend aws_lb_listener (web tier)
resource "aws_lb_listener" "elpharco-webtier-listener" {
  load_balancer_arn = aws_lb.elpharco-webtier-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elpharco-webtier-target-group-alb.arn
  }
}

# Frontend aws_lb target group to target the webtier ec2 instances
resource "aws_lb_target_group" "elpharco-webtier-target-group-alb" {
  name     = "elpharco-webtier-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.elpharco-webApp.id
  target_type = "instance"

  health_check {
    enabled = true
    path                = "/"
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 65
    interval            = 70
    unhealthy_threshold = 3
    healthy_threshold   = 3
  }

  tags = {
    Name = "webtier-target-group"
  }
}

# Frontend aws_lb target group attachment
resource "aws_autoscaling_attachment" "elpharco-webtier-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.elpharco-webtier-asg.id
  lb_target_group_arn    = aws_lb_target_group.elpharco-webtier-target-group-alb.arn
}

#####################################################################################################################################################################
######################################################################################################################################################################

# aws_lb for the apptier backtend servers
resource "aws_lb" "elpharco-apptier-alb" {
  name               = "elpharco-apptier-alb"
  internal           = true  # This alb is internal (not internet-facing) since traffic will be routed from the webtier, and not the Internet
  load_balancer_type = "application"
  #ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.elpharco-apptier-alb-sg.id] 
  subnets            = [aws_subnet.elpharco-apptier-private-snet-01.id, aws_subnet.elpharco-apptier-private-snet-02.id]  # private subnet IDs

  tags = {
    Name = "apptier-alb"
  }
}

# Backend aws_lb_listener
resource "aws_lb_listener" "elpharco-apptier-listener" {
  load_balancer_arn = aws_lb.elpharco-apptier-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elpharco-apptier-target-group-alb.arn
  }
}

# Backend aws_lb target group to target the apptier ec2 instances
resource "aws_lb_target_group" "elpharco-apptier-target-group-alb" {
  name     = "elpharco-apptier-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.elpharco-webApp.id
  target_type = "instance"

  health_check {
    enabled = true
    path                = "/"
    matcher             = 200
    port                = 80
    protocol            = "HTTP"
    timeout             = 65
    interval            = 70
    unhealthy_threshold = 2
    healthy_threshold   = 2
  }

  tags = {
    Name = "apptier-target-group"
  }
}

# Backend aws_lb target group attachment
resource "aws_autoscaling_attachment" "elpharco-apptier-asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.elpharco-apptier-asg.id
  lb_target_group_arn    = aws_lb_target_group.elpharco-apptier-target-group-alb.arn
}

