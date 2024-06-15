#!/bin/bash

# Step 1: Install Docker using Snap if not already installed
if ! snap list | grep -q docker; then
  sudo snap install docker
else
  echo "Docker is already installed."
fi

# Step 2: Create Docker group if it does not exist
if ! getent group docker > /dev/null; then
  sudo groupadd docker
else
  echo "Docker group already exists."
fi

# Step 3: Add vagrant user to Docker group if not already a member
if ! groups vagrant | grep -q docker; then
  sudo usermod -aG docker vagrant
else
  echo "User 'vagrant' is already in the Docker group."
fi

# Step 4: Ensure Docker socket permissions are correct
sudo chmod 666 /var/run/docker.sock

# Step 5: Prompt for Docker Hub credentials and log in
echo "Please enter your Docker Hub username:"
read DOCKER_USERNAME
echo "Please enter your Docker Hub password:"
read -s DOCKER_PASSWORD

# Step 6: Create a temporary Docker config file with login credentials
mkdir -p ~/.docker
cat <<EOF > ~/.docker/config.json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "auth": "$(echo -n $DOCKER_USERNAME:$DOCKER_PASSWORD | base64)"
    }
  }
}
EOF

# Step 7: Verify Docker setup
newgrp docker <<EONG
sudo docker ps
sudo docker images
EONG

echo "Docker setup for user 'vagrant' is complete. Please log out and log back in to apply group changes."
