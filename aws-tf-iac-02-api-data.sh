#!/bin/bash

# Install apache2
sudo apt update -y
sudo apt install apache2 -y
sudo systemctl start apache2
sudo systemctl enable apache2
sudo bash -c 'echo your very first web server > /var/www/html/index.html'

# Install Docker on Ubuntu from official Repository
sudo apt update -y 
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
sudo apt update -y
sudo apt-get install docker-ce -y
sudo systemctl start docker
sudo systemctl enable docker




# Installing Docker on Amazon Linux
#sudo yum update -y
#sudo amazon-linux-extras install docker
#sudo yum install docker
#sudo service docker start
#sudo usermod -a -G docker ec2-user

