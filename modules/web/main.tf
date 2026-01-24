
# aws_launch_template for the webtier frontend servers
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

# security groups associated with the webtier architecture
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

# auto scaling group for the web-tier frontend servers
# automatically launches and terminates ec2 instances across multiple AZs, using the public subnets provided by the network module.
# ensures high availability by distributing instances across public subnets and scaling capacity based on demand.
resource "aws_autoscaling_group" "arco_web_asg" {
  name_prefix = "web_asg"
  #availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.arco_pub_subnet_01.id, aws_subnet.arco_pub_subnet_02.id]  # public subnet ids
  target_group_arns = [aws_lb_target_group.arco_web_target_grp_alb.arn]
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
    value               = "web_instance"
    propagate_at_launch = true
  }
}

# target-tracking scaling policy for the web asg.
# adjusts capacity automatically based on average cpu utilization
# ensures the asg scales out/in to maintain the desired cpu threshold
# maintains performance by adjusting instance count according to load
resource "aws_autoscaling_policy" "web_cpu_policy" {
  name                   = "cpu_scaling_policy"
  policy_type            = "targetTrackingScaling"
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