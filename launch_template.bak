
# aws_launch_template for the webtier frontend servers
resource "aws_launch_template" "elpharco-webtier-config" {
  name_prefix   = "webtier-template"
  image_id      = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  key_name = "elpharco-keyPair"
  vpc_security_group_ids = [aws_security_group.elpharco-webtier-sg.id]
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
      Name = "webtier-template"
    }
}
#################################################################################################################################################################
#################################################################################################################################################################

### Bastion host instance to securely access the apptier servers [The ec2 instance will be created in the webtier, outside the ASG]
# This Bastion host acts as a jump server, allowing us to connect to the Application Tier instances without exposing them to the public internet.
resource "aws_instance" "bastion-host-instance" {

  ami           = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  key_name      = var.key-name
  #associate_public_ip_address = true
  subnet_id     = aws_subnet.elpharco-webtier-public-snet-01.id
  security_groups = [aws_security_group.elpharco-bastion-host-ssh-sg.id]
  #availability_zone = var.Instance1-availability-zone

  tags = {
    Name = "bastion_instance"

  }

}
##################################################################################################################################################################
###################################################################################################################################################################

# aws_launch_template for the apptier backend servers
resource "aws_launch_template" "elpharco-apptier-config" {
  name_prefix   = "apptier-template"
  image_id      = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  key_name = "elpharco-keyPair"
  vpc_security_group_ids = [aws_security_group.elpharco-apptier-sg.id]
  user_data = filebase64("base64encode.sh")
  #user_data = file("userdata.sh")

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 10
      volume_type = "gp2"
      encrypted   = true
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
      Name = "apptier-template"
    }
}

#########################################################################################################################################################
#########################################################################################################################################################

# RDS deployment for the elpharco webApp DB tier
resource "aws_db_instance" "elpharco-webApp-db" {
  allocated_storage    = 10
  storage_type         = "gp2"
  #db_name              = "elpharco-db"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  identifier           = "mydb"
  username             = "Admin"
  password             = "adminuser1"
  #parameter_group_name = "default.mysql5.7"

  vpc_security_group_ids = [aws_security_group.elpharco-dbtier-sg.id]
  db_subnet_group_name = aws_db_subnet_group.elpharco-db-snet-grp.name

  backup_retention_period = 7 # Number of days to retain automated backups
  backup_window = "03:00-04:00" # Preferred UTC backup window (hh24:mi-hh24:mi format)
  maintenance_window = "mon:04:00-mon:04:30" # Preferred UTC maintenance window
  
  multi_az = true
  #storage_encrypted           = true

  skip_final_snapshot  = true // required to destroy
}


