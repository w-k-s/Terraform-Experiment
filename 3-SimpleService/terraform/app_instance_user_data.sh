#!/bin/bash

# Define variables
WORKING_DIRECTORY=/opt/todo
AWS_REGION=ap-south-1
JAR_NAME=app.jar
S3_APP_BUCKET=s3://io.wks.terraform.todobackend
S3_EXECUTABLE_PATH="$S3_APP_BUCKET/$JAR_NAME"
EXECUTABLE_PATH="$WORKING_DIRECTORY/$JAR_NAME"
APP_USER=todo-user
SERVICE_NAME=todo

# install updates
sudo apt-get update && sudo apt-get -y upgrade

# Install apache
sudo apt-get install apache2

# Install java 19
wget https://download.oracle.com/java/19/latest/jdk-19_linux-x64_bin.deb
sudo apt-get -qqy install ./jdk-19_linux-x64_bin.deb
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-19/bin/java 1919

# Setup Firewall
sudo ufw allow 'Apache'

# create the working directory
mkdir "$WORKING_DIRECTORY"
# Note: we could set environment variables here, but I'm not that kinda guy

# Download the maven artifact from S3
aws s3 cp "$S3_EXECUTABLE_PATH" "$WORKING_DIRECTORY" --region="$AWS_REGION"

# create a user, todo-user, to run the app as a service
useradd "$APP_USER"

# todo_user login shell disabled
chsh -s /sbin/nologin "$APP_USER"
chown "$APP_USER":"$APP_USER" "$EXECUTABLE_PATH"
chmod 500 "$EXECUTABLE_PATH"

# create a symbolic link
ln -s "$EXECUTABLE_PATH" "/etc/init.d/$SERVICE_NAME"

# forward port 80 to 8080
echo "<VirtualHost *:80>
ProxyRequests Off
ProxyPass / http://localhost:8080/
ProxyPassReverse / http://localhost:8080/
</VirtualHost>" >> /etc/httpd/conf/httpd.conf

# start the httpd and spring-boot-ec2-demo
service httpd start
service "$SERVICE_NAME" start

# automatically start httpd and spring-boot-ec2-demo if this ec2 instance reboots
chkconfig httpd on
chkconfig "$SERVICE_NAME" on