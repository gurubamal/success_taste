#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Get the IP address from the routing table
IP=$(ip r s | grep 192.168.58 | awk '{print $NF}')
if [ -z "$IP" ]; then
  echo "Error: IP address not found in routing table."
fi

# Set the hostname
HOSTNAME="node$(echo $IP | cut -d'.' -f4)"
sudo hostnamectl set-hostname "$HOSTNAME"
if [ $? -ne 0 ]; then
  echo "Error: Failed to set hostname."
fi

# Check and update /etc/hosts
if ! grep -q "192.168.58" /etc/hosts; then
  {
    echo "192.168.58.7        node7   node02"
    echo "192.168.58.8        node8   node03"
    echo "192.168.58.6        node6   node01"
    echo "192.168.58.5        node5  controller"
  } | sudo tee -a /etc/hosts > /dev/null

  if [ $? -ne 0 ]; then
    echo "Error: Failed to update /etc/hosts."
  fi
fi

# Update sshd_config to allow password authentication
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
if [ $? -ne 0 ]; then
  echo "Error: Failed to update sshd_config."
fi

# Restart the SSH service
sudo systemctl restart ssh
if [ $? -ne 0 ]; then
  echo "Error: Failed to restart SSH service."
fi

# Additional entries to /etc/fstab and /etc/hosts (commented out in the original)
#echo "vagrant /vagrant vboxsf uid=1000,gid=1000,_netdev 0 0" | sudo tee -a /etc/fstab
#echo "$IP node$(ip r s | grep 10.0.3 | awk '{print $NF}' | cut -d'.' -f4)" | sudo tee -a /etc/hosts
