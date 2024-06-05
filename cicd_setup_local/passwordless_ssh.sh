#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Install sshpass
sudo apt -y install sshpass
if [ $? -ne 0 ]; then
  echo "Error: Failed to install sshpass."
fi

# Generate SSH key pair
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y >/dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate SSH key pair."
fi

# Copy SSH key to nodes
for i in 6 7 8 9; do
  sshpass -p vagrant ssh-copy-id vagrant@node$i
  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy SSH key to vagrant@node$i."
  fi

  sudo sshpass -p vagrant sudo ssh-copy-id root@node$i
  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy SSH key to root@node$i."
  fi
done
