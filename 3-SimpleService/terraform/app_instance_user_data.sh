#!/bin/bash
# File Stored on ec2 ubuntu server at: /var/lib/cloud/instance/user-data.txt
# Output stored on ec2 ubuntu server at in:  /var/log/cloud-init-output.log

####### VARIABLES

WORKING_DIRECTORY=/opt/todo
AWS_REGION=${aws_region}
JAR_NAME=${jar_name}
S3_APP_BUCKET=${s3_app_bucket}
S3_EXECUTABLE_PATH="s3://$S3_APP_BUCKET/$JAR_NAME"
LOCAL_EXECUTABLE_PATH="$WORKING_DIRECTORY/$JAR_NAME"
SERVICE_NAME=todo

CLOUDWATCH_CONFIG_FILE_NAME=amazon-cloudwatch-agent.json
S3_CLOUDWATCH_CONFIG_PATH="s3://$S3_APP_BUCKET/$CLOUDWATCH_CONFIG_FILE_NAME"
LOCAL_CLOUDWATCH_CONFIG_DIR=/opt/aws/amazon-cloudwatch-agent/etc/

LOG_DIRECTORY=${application_log_directory}
LOG_FILE_NAME=${application_log_file_name}

echo "S3_EXECUTABLE_PATH: '$S3_EXECUTABLE_PATH'"
echo "EXECUTABLE_PATH: '$LOCAL_EXECUTABLE_PATH'"
echo "REGION: '$AWS_REGION' "
echo "LOG_DIRECTORY: '$LOG_DIRECTORY'"
echo "S3_CLOUDWATCH_CONFIG_PATH: '$S3_CLOUDWATCH_CONFIG_PATH'"

####### INSTALLATIONS

# Update aptitude repository
sudo apt-get update && sudo apt-get -y upgrade

# Install Awscli (on ubuntu)
sudo apt-get install awscli -y

# # Install Apache
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

# Add todo-user to the admin group
sudo usermod -aG admin todo-user

# todo_user login shell disabled
sudo chsh -s /sbin/nologin todo-user

# set todo-user as the owner of executable
sudo chown todo-user:todo-user "$LOCAL_EXECUTABLE_PATH"

# Add executable permission to jar
sudo chmod u+x "$LOCAL_EXECUTABLE_PATH"

# Set up log directory
sudo mkdir -p "$LOG_DIRECTORY"
sudo chown todo-user:todo-user "$LOG_DIRECTORY"

# Create todo service daemon
sudo mkdir -p /etc/systemd/system/
sudo touch /etc/systemd/system/todo.service

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
ExecStart=java -jar -Dlogging.file.path=$LOG_DIRECTORY -Dlogging.file.name=$LOG_FILE_NAME $LOCAL_EXECUTABLE_PATH
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
ErrorLog $${APACHE_LOG_DIR}/error.log
CustomLog $${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" | sudo tee /etc/apache2/sites-available/todo.conf

# Disable the default site
sudo a2dissite 000-default.conf
# Enable the todo site
sudo a2ensite todo

# start the apache2 service
sudo systemctl reload apache2

##### CLOUDWATCH

# Downlod the cloudwatch agent
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

# Install the cloudwatch agent
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Download the cloudwatch file
sudo mkdir -p "$LOCAL_CLOUDWATCH_CONFIG_DIR"
sudo aws s3 cp "$S3_CLOUDWATCH_CONFIG_PATH" "$LOCAL_CLOUDWATCH_CONFIG_DIR" --region="$AWS_REGION"

# Use cloudwatch config from SSM
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-s \
-c "file:$LOCAL_CLOUDWATCH_CONFIG_DIR/$CLOUDWATCH_CONFIG_FILE_NAME"

