#!/bin/bash

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee   /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian-stable binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update ; sudo apt -y install openjdk-11-jre

sudo apt-get -y  install jenkins

if [ $(echo $?) = 0 ]
then echo "Jenkins server is available at http://192.168.58.6:8080"
	  JENKIN8_PASSWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
	  echo $JENKIN8_PASSWD is your first time jenkins password
  else sudo apt -y remove jenkins ; sudo apt -y install jenkins
fi
