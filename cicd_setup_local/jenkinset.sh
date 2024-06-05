#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Add Jenkins repository key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Jenkins repository key."
fi

# Add Jenkins repository to sources list
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Jenkins repository to sources list."
fi

# Update package list and install OpenJDK 11
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt -y install openjdk-11-jre
if [ $? -ne 0 ]; then
  echo "Error: Failed to install OpenJDK 11."
fi

# Install Jenkins
sudo apt-get -y install jenkins
if [ $? -eq 0 ]; then
  echo "Jenkins server is available at http://192.168.58.8:8080"
  JENKIN8_PASSWD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
  if [ $? -ne 0 ]; then
    echo "Error: Failed to retrieve initial Jenkins password."
  else
    echo "$JENKIN8_PASSWD is your first time Jenkins password"
  fi
else
  echo "Error: Jenkins installation failed. Attempting to reinstall Jenkins."
  sudo apt -y remove jenkins
  if [ $? -ne 0 ]; then
    echo "Error: Failed to remove Jenkins."
  fi
  sudo apt -y install jenkins
  if [ $? -ne 0 ]; then
    echo "Error: Reinstallation of Jenkins failed."
  fi
fi
