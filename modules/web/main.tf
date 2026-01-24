
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