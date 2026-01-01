
#!/bin/bash

#Update all yum package repositories
sudo yum update -y

#Install Apache Web Server
sudo yum install -y httpd.x86_64

#Start and Enable Apache Web Server
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

#Adds our custom webpage html code to "index.html" file.
sudo echo "<h1>Elpharco WebApp Project Completed!</h1>" > /var/www/html/index.html

