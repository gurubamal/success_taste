#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Clear known hosts file
> ~/.ssh/known_hosts
if [ $? -ne 0 ]; then
  echo "Error: Failed to clear ~/.ssh/known_hosts."
  exit 1
fi

# Copy SSH key to each node
for i in 6 7 8; do
  sshpass -f password.txt ssh-copy-id -o StrictHostKeyChecking=no vagrant@10.0.3.$i
  if [ $? -ne 0 ]; then
    echo "Error: Failed to copy SSH key to 10.0.3.$i."
  fi
done
