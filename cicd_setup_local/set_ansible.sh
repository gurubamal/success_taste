#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Add Ansible PPA repository
sudo apt-add-repository ppa:ansible/ansible -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Ansible PPA repository."
fi

# Update package list
sudo apt update -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

# Install Ansible and dependencies
sudo apt install ansible -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Ansible."
fi

sudo apt -y install ansible-core ansible --allow-change-held-packages
if [ $? -ne 0 ]; then
  echo "Error: Failed to install ansible-core and Ansible."
fi

# Configure Ansible hosts file
echo "[servers]
node6 ansible_host=192.168.58.6
node7 ansible_host=192.168.58.7
node8 ansible_host=192.168.58.8
node9 ansible_host=192.168.58.9

[all:vars]
ansible_python_interpreter=/usr/bin/python3" | sudo tee /etc/ansible/hosts
if [ $? -ne 0 ]; then
  echo "Error: Failed to configure Ansible hosts file."
fi

# Update package list and manage Docker installation
sudo apt update -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt -y remove containerd.io
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove containerd.io."
fi

sudo apt -y install docker.io
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Docker."
fi

sudo apt -y autoremove
if [ $? -ne 0 ]; then
  echo "Error: Failed to autoremove unnecessary packages."
fi

# Configure Docker registry
sudo mkdir -p /etc/docker/registry
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /etc/docker/registry directory."
fi

echo "version: 0.1
storage:
  filesystem:
    rootdirectory: /var/lib/registry
" | sudo tee /etc/docker/registry/config.yml
if [ $? -ne 0 ]; then
  echo "Error: Failed to configure Docker registry."
fi

# Add vagrant user to Docker group
sudo usermod -aG docker vagrant
if [ $? -ne 0 ]; then
  echo "Error: Failed to add vagrant user to Docker group."
fi

# Manage Docker service
sudo systemctl unmask docker.service
if [ $? -ne 0 ]; then
  echo "Error: Failed to unmask Docker service."
fi

sudo systemctl enable docker.service
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable Docker service."
fi

sudo systemctl start docker.service
if [ $? -ne 0 ]; then
  echo "Error: Failed to start Docker service."
fi

# Run Docker registry
docker run -d -p 5000:5000 --restart=always --name registry registry:2
if [ $? -ne 0 ]; then
  echo "Error: Failed to run Docker registry."
fi

docker ps
if [ $? -ne 0 ]; then
  echo "Error: Failed to list running Docker containers."
fi
