
# Security groups associated with the webtier architecture
resource "aws_security_group" "elpharco-webtier-sg" {
  name        = "elpharco-webtier-sg"
  description = "allow ssh on port 22 & http on port 80"  # Security group for instances launched by the launch template
  vpc_id      = aws_vpc.elpharco-webApp.id

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
    #security_groups  = [aws_security_group.elpharco-webtier-alb-sg.id]
  }

# Outbound Rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "webtier-sg"
  }
}

# Webtier aws_lb security group
resource "aws_security_group" "elpharco-webtier-alb-sg" {
  name        = "elpharco-webtier-alb-sg"
  description = "allow http on port 80"  #Security group for the application load balancer
  vpc_id      = aws_vpc.elpharco-webApp.id

  // Define ingress rules for the security group
  // Example: Allow inbound HTTP traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow http traffic from anywhere (you may want to restrict this)
  }

  // Define egress rules for the security group
  // Example: Allow outbound traffic to anywhere
  # Outbound Rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webtier-alb-sg"
  }
}
#####################################################################################################################
#####################################################################################################################

# Bastion-host Security group (inbound rule)
resource "aws_security_group" "elpharco-bastion-host-ssh-sg" {
  name        = "bastion-ssh-sg"
  description = "Allow ssh to bastion hosts from my ip"
  vpc_id      = aws_vpc.elpharco-webApp.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can specify my ip (../32)
  }

  # Outbound Rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

######################################################################################################################
######################################################################################################################

# Security groups associated with the apptier architecture
resource "aws_security_group" "elpharco-apptier-sg" {
  name        = "elpharco-apptier-sg"
  description = "allow ssh on port 22 from bastion host & icmp echo/ping (8) from the web servers"  # Security group for instances launched by the launch template
  vpc_id      = aws_vpc.elpharco-webApp.id

// Inbound ssh frm bastion
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.elpharco-bastion-host-ssh-sg.id] # bastion security group id
    description       = "Allow ssh from bastion host"
  }

// Ping from the web servers
  ingress { 
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    security_groups  = [aws_security_group.elpharco-webtier-sg.id]
    description      = "Allow ping from the web servers"
  }

# Outbound Rules
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "apptier-sg"
  }
}

# Apptier aws_lb security group
resource "aws_security_group" "elpharco-apptier-alb-sg" {
  name        = "elpharco-apptier-alb-sg"
  description = "allow http on port 80"  #Security group for the application load balancer
  vpc_id      = aws_vpc.elpharco-webApp.id

  // Define ingress rules for the security group
  // Allow inbound HTTP traffic from the security group of the webtier alb
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups  = [aws_security_group.elpharco-webtier-alb-sg.id] 
  }

  // Define egress rules for the security group
  // Example: Allow outbound traffic to anywhere
  # Outbound Rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "apptier-alb-sg"
  }
}

######################################################################################################################
######################################################################################################################

# Security groups associated with the dbtier architecture
resource "aws_security_group" "elpharco-dbtier-sg" {
  name        = "elpharco-dbtier-sg"
  description = "allow inbound and outbound traffic from the apptier servers"  # 
  vpc_id      = aws_vpc.elpharco-webApp.id

// Inbound Rules
  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.elpharco-apptier-sg.id] # apptier security group id
    description       = "Allow MySQL requests on port 3306"
  }

# Outbound Rules
  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    security_groups  = [aws_security_group.elpharco-apptier-sg.id]
  }
  tags = {
    Name = "dbtier-sg"
  }
}
