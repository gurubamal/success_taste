#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Add entries to /etc/hosts if not already present
if ! grep -q 192.168.58 /etc/hosts; then
    echo "192.168.58.7 node7 node02" | sudo tee -a /etc/hosts
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add node7 to /etc/hosts."
    fi

    echo "192.168.58.8 node8 node03" | sudo tee -a /etc/hosts
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add node8 to /etc/hosts."
    fi

    echo "192.168.58.6 node6 node01" | sudo tee -a /etc/hosts
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add node6 to /etc/hosts."
    fi

    echo "192.168.58.9 node9 controller" | sudo tee -a /etc/hosts
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add node9 to /etc/hosts."
    fi
fi

# Update SSH configuration
if ! grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config; then
    sudo sed -i "s/\#PasswordAuthentication yes/PasswordAuthentication yes/g" /etc/ssh/sshd_config
    echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config
    sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update PasswordAuthentication in /etc/ssh/sshd_config."
    fi
fi

if ! grep -q "PermitRootLogin yes" /etc/ssh/sshd_config; then
    echo "PermitRootLogin yes" | sudo tee -a /etc/ssh/sshd_config
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add PermitRootLogin to /etc/ssh/sshd_config."
    fi
fi

if ! grep -q "StrictHostKeyChecking no" /etc/ssh/ssh_config; then
    echo "StrictHostKeyChecking no" | sudo tee -a /etc/ssh/ssh_config
    if [ $? -ne 0 ]; then
        echo "Error: Failed to add StrictHostKeyChecking to /etc/ssh/ssh_config."
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
    fi
fi
