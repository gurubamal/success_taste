#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Update /etc/hosts if necessary
if ! grep -q "192.168.58" /etc/hosts; then
  echo "192.168.58.7        node7   node02" | sudo tee -a /etc/hosts
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add node7 to /etc/hosts."
  fi

  echo "192.168.58.8        node8   node03" | sudo tee -a /etc/hosts
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add node8 to /etc/hosts."
  fi

  echo "192.168.58.6        node6   node01" | sudo tee -a /etc/hosts
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add node6 to /etc/hosts."
  fi

  echo "192.168.58.9        node9  controller" | sudo tee -a /etc/hosts
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add node9 to /etc/hosts."
  fi
fi

# Ensure PasswordAuthentication is enabled
if ! grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config; then
  sudo sed -i "s/\#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to uncomment PasswordAuthentication in /etc/ssh/sshd_config."
  fi

  echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add PasswordAuthentication yes to /etc/ssh/sshd_config."
  fi

  sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to replace PasswordAuthentication no with yes in /etc/ssh/sshd_config."
  fi
fi

# Ensure PermitRootLogin is enabled
if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
  echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add PermitRootLogin yes to /etc/ssh/sshd_config."
  fi
fi

# Ensure StrictHostKeyChecking is disabled
if ! grep -q "StrictHostKeyChecking no" /etc/ssh/ssh_config; then
  echo "StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add StrictHostKeyChecking no to /etc/ssh/ssh_config."
  fi
fi

# Restart SSH service
sudo systemctl restart ssh
if [ $? -ne 0 ]; then
  echo "Error: Failed to restart SSH service."
fi

# Reset root password if not already done
FILEX=/home/vagrant/x.txt
if test -f "$FILEX"; then
  echo "Password was reset already."
else
  echo -e "vagrant\nvagrant" | sudo passwd root
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reset root password."
  else
    touch $FILEX
    if [ $? -ne 0 ]; then
      echo "Error: Failed to create x.txt to indicate password reset."
    fi
  fi
fi
