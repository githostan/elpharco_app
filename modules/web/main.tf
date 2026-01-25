
### launch_template for the webtier frontend servers ########################################################
resource "aws_launch_template" "arco_web" {
  name_prefix   = "web_temp"
  image_id      = var.os_name
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.arco_web_sg.id]
  user_data = filebase64("base_ami_config.sh")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 10
    }
  }

  monitoring {
    enabled = true
  }

# we can't modify a launch configuration, so any changes to the definition force terraform 
# to create a new resource. The create_before_destroy argument in the lifecycle block instructs 
# terraform to create the new version before destroying the original to avoid any service interruptions.
# lifecycle {
#     create_before_destroy = true
#   }

    tags = {
      Name = "web_temp"
    }
}
#################################################################################################################################################################
#################################################################################################################################################################

### web tier security groups ########################################################
resource "aws_security_group" "arco_web_sg" {
  name        = "arco_web_sg"
  description = "allow ssh on port 22 & http on port 80"  # Security group for instances launched by the launch template
  vpc_id      = var.vpc_id

// define inbound and outbound rules as needed
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #security_groups  = [aws_security_group.arco_web_alb_sg.id]
  }

# outbound rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "web_sg"
  }
}
######################################################################################################################################################
#######################################################################################################################################################

# asg automatically launches & terminates ec2 instances across multi-AZs, using the public subnets provided by the network module.
# ensures high availability by distributing instances across public subnets and scaling capacity based on demand.

### auto scaling group for the web-tier frontend servers ########################################################
resource "aws_autoscaling_group" "arco_web_asg" {
  name_prefix = "web_asg"
  #availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  vpc_zone_identifier = var.public_subnet_ids  # public subnet ids
  target_group_arns = [aws_lb_target_group.arco_web_tg.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300  # Optional but recommended

  launch_template {
    id      = aws_launch_template.arco_web.id
    version = "$Latest"
  }

# When replacing a resource, terraform would normally delete the old resource first and then create the replacement.
# However, as ASG now has a reference to the old resource, Terraform will not be able to delete it, and as such, we use 
# the lifecycle setting called “Create before destroy” to force terraform to create the replacement resource first prior to deleting the old resource
 lifecycle { 
     create_before_destroy = true
   }

   tag {
    key                 = "Name"
    value               = "web_server"
    propagate_at_launch = true
  }
}

# target-tracking scaling policy for the web asg.
# adjusts capacity automatically based on average cpu utilization
# ensures the asg scales out/in to maintain the desired cpu threshold
# maintains performance by adjusting instance count according to load
resource "aws_autoscaling_policy" "web_cpu_policy" {
  name                   = "cpu_scaling_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.arco_web_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 90.0  # target cpu utilization
  }
}
######################################################################################################################################################
#######################################################################################################################################################

# application load balancer distributing traffic to the web-tier / routing external traffic to the asg instances

### alb for the web tier frontend servers ########################################################
resource "aws_lb" "arco_web_alb" {
  name               = "arco-web-alb"
  internal           = false  # The alb is Internet-facing and not internal
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.arco_web_alb_sg.id] 
  subnets            = var.public_subnet_ids  # public subnet IDs

  tags = {
    Name = "web_alb"
  }
}

# frontend listener for the web tier alb, forwarding http traffic to the target group
# web tier alb listener handling inbound http traffic

### alb listener for the web-tier (frontend) ########################################################
resource "aws_lb_listener" "arco_web_listener" {
  load_balancer_arn = aws_lb.arco_web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.arco_web_tg.arn
  }
}

# alb target group for routing traffic to the web tier instances
resource "aws_lb_target_group" "arco_web_tg" {
  name     = "arco-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
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
    Name = "web_target_grp"
  }
}

# frontend lb target group attachment
resource "aws_autoscaling_attachment" "arco_web_asg_attach" {
  autoscaling_group_name = aws_autoscaling_group.arco_web_asg.id
  lb_target_group_arn    = aws_lb_target_group.arco_web_tg.arn
}

#####################################################################################################################################################################
######################################################################################################################################################################

### webtier alb security group ########################################################
resource "aws_security_group" "arco_web_alb_sg" {
  name        = "arco_web_alb_sg"
  description = "allow http on port 80"  #Security group for the application load balancer
  vpc_id      = var.vpc_id

  // define ingress rules for the security group
  // example: Allow inbound http traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # allow http traffic from anywhere (you may want to restrict this)
  }

  // define egress rules for the security group
  // example: allow outbound traffic to anywhere
  # outbound rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_alb_sg"
  }
}
#####################################################################################################################
#####################################################################################################################