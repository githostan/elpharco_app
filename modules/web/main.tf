
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

# We can't modify a launch configuration, so any changes to the definition force terraform 
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

// Define inbound and outbound rules as needed
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

# Outbound Rules
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
