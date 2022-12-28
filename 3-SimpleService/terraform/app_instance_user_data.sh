#!/bin/bash

####### VARIABLES

WORKING_DIRECTORY=/opt/todo
AWS_REGION=ap-south-1
JAR_NAME=app.jar
S3_APP_BUCKET=s3://io.wks.terraform.todobackend
S3_EXECUTABLE_PATH="$S3_APP_BUCKET/$JAR_NAME"
EXECUTABLE_PATH="$WORKING_DIRECTORY/$JAR_NAME"
SERVICE_NAME=todo

####### INSTALLATIONS

# install updates
sudo apt-get update && sudo apt-get -y upgrade

# Install Awscli (on ubuntu)
sudo apt-get install awscli -y

# # Install apache
sudo apt-get install apache2 -y

# Install java 19
sudo wget https://download.oracle.com/java/19/latest/jdk-19_linux-x64_bin.deb
sudo apt-get -qqy install ./jdk-19_linux-x64_bin.deb
sudo update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-19/bin/java 1919


####### APPLICATION CONFIGURATION

# create the working directory
mkdir "$WORKING_DIRECTORY"

# Download the maven artifact from S3
sudo aws s3 cp "$S3_EXECUTABLE_PATH" "$WORKING_DIRECTORY" --region="$AWS_REGION"

# create a user, todo-user, to run the app as a service
sudo useradd todo-user
sudo usermod -aG admin todo-user

# todo_user login shell disabled
sudo chsh -s /sbin/nologin todo-user
sudo chown todo-user:todo-user "$EXECUTABLE_PATH"
sudo chmod u+x "$EXECUTABLE_PATH"

# create a symbolic link
sudo mkdir -p /etc/systemd/system/
sudo touch /etc/systemd/system/todo.service
#sudo chown ubuntu /etc/systemd/system/todo.service

sudo echo "[Unit]
Description=Todo Spring Boot application service

[Socket]
ListenStream=8080
NoDelay=true

[Service]
User=todo-user
Group=admin
Type=simple
Restart=on-failure
RestartSec=10
ExecStart=
ExecStart=java -jar $EXECUTABLE_PATH
WorkingDirectory=$WORKING_DIRECTORY
ExitStatus=143

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/todo.service

# start the todo service
sudo systemctl enable todo
sudo service  todo start

####### APACHE CONFIGURATION

sudo a2enmod proxy
sudo a2enmod headers
sudo a2enmod proxy_http
sudo systemctl restart apache2

# Setup Firewall
sudo ufw allow 'Apache'

# Set up port-forwarding with apache
sudo mkdir -p /etc/apache2/sites-available
sudo touch /etc/apache2/sites-available/todo.conf
sudo echo "<VirtualHost *:80>
ProxyPreserveHost on
RequestHeader set X-Forwarded-Proto https
RequestHeader set X-Forwarded-Port 443
ProxyPass / http://127.0.0.1:8080/
ProxyPassReverse / http://127.0.0.1:8080/
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/todo.conf

sudo a2ensite todo

# start the apache2 service
sudo systemctl reload apache2