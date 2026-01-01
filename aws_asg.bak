
# aws_autoscaling_group for the webtier frontend servers
# ASG will dynamically provision EC2 instances as required across multiple AZs in our public subnets
resource "aws_autoscaling_group" "elpharco-webtier-asg" {
  name_prefix = "webtier-asg"
  #availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.elpharco-webtier-public-snet-01.id, aws_subnet.elpharco-webtier-public-snet-02.id]  # public subnet IDs
  target_group_arns = [aws_lb_target_group.elpharco-webtier-target-group-alb.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300  # Optional but recommended

  launch_template {
    id      = aws_launch_template.elpharco-webtier-config.id
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
    value               = "webtier_instance"
    propagate_at_launch = true
  }
}

# AWS Autoscaling Policy - Target tracking policy for CPU utilization
resource "aws_autoscaling_policy" "webtier-target-tracking-policy" {
  name                   = "cpu_scaling_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.elpharco-webtier-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 90.0  # Target CPU utilization
  }
}

######################################################################################################################################################
#######################################################################################################################################################

# aws_autoscaling_group for the apptier backend servers
resource "aws_autoscaling_group" "elpharco-apptier-asg" {
  name_prefix = "apptier-asg"
  #availability_zones = ["us-east-1a", "us-east-1b"]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.elpharco-apptier-private-snet-01.id, aws_subnet.elpharco-apptier-private-snet-02.id]  # private subnet IDs
  target_group_arns = [aws_lb_target_group.elpharco-apptier-target-group-alb.arn]
  health_check_type = "ELB"
  health_check_grace_period = 300  # Optional but recommended

  launch_template {
    id      = aws_launch_template.elpharco-apptier-config.id
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
    value               = "apptier_instance"
    propagate_at_launch = true
  }
}

# AWS Autoscaling Policy - Target tracking policy for CPU utilization
resource "aws_autoscaling_policy" "apptier-target-tracking-policy" {
  name                   = "cpu_scaling_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.elpharco-apptier-asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 90.0  # Target CPU utilization
  }
}

