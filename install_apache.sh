#Script to help test if the jumpbox is correctly configured or not
#It'll display the host name for anyone who connects over port 80
#!/bin/bash

yum update -y
yum install -y httpd.x86_64
systemctl start httpd.service
systemctl enable httpd.service
echo "Hello World from $(hostname -f)" > /var/www/html/index.html