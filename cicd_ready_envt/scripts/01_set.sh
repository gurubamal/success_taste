#!/bin/bash

check_internet() {
    local url="http://www.google.com"
    curl --silent --head --fail "$url" > /dev/null
    if [ $? -ne 0 ]; then
        echo "No internet connection. Exiting..."
        exit 1
    else
        echo "Internet is available."
    fi
}

# Call the check_internet function at the beginning of your script
check_internet

# Create the systemd service file for disabling swap
sudo tee /etc/systemd/system/swapoff.service > /dev/null <<EOF
[Unit]
Description=Disable Swap
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/sbin/swapoff -a
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
sudo systemctl daemon-reload

# Enable the service to run at startup
sudo systemctl enable swapoff.service

# Optionally start the service immediately
sudo systemctl start swapoff.service

echo "Swapoff service has been created and enabled."

# Install necessary packages
sudo apt-get update -y
sudo apt-get install -y linux-headers-$(uname -r) build-essential dkms

echo "Removing old repository configurations..."
sudo rm -rf /etc/apt/sources.list.d/*

echo "Resetting sources list..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) main restricted
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates main restricted
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates universe
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) multiverse
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-updates multiverse
deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc)-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu $(lsb_release -sc)-security main restricted
deb http://security.ubuntu.com/ubuntu $(lsb_release -sc)-security universe
deb http://security.ubuntu.com/ubuntu $(lsb_release -sc)-security multiverse
EOF

echo "Adding fresh repository and keys..."
sudo apt-get update -y
sudo apt-get install -y software-properties-common

echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Define the content of the ping script
PING_SCRIPT_CONTENT='#!/bin/bash

while true; do
    if ping -c 1 192.168.56.2 &> /dev/null
    then
        echo "192.168.56.2 is up"
    else
        echo "192.168.56.2 is down"
    fi
    sleep 2
done
'

# Define the content of the systemd service
SERVICE_CONTENT='[Unit]
Description=Ping Gateway Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ping_gateway.sh
Restart=always

[Install]
WantedBy=multi-user.target
'

# Create the ping script
echo "Creating /usr/local/bin/ping_gateway.sh..."
echo "$PING_SCRIPT_CONTENT" | sudo tee /usr/local/bin/ping_gateway.sh > /dev/null
sudo chmod +x /usr/local/bin/ping_gateway.sh

# Create the systemd service file
echo "Creating /etc/systemd/system/ping_gateway.service..."
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/ping_gateway.service > /dev/null

# Reload systemd, enable and start the service
echo "Reloading systemd, enabling and starting the ping_gateway service..."
sudo systemctl daemon-reload
sudo systemctl enable ping_gateway.service
sudo systemctl start ping_gateway.service

# Check the status of the service
echo "Checking the status of the ping_gateway service..."
sudo systemctl status ping_gateway.service

# Function to check if Python is installed
check_python() {
    if command -v python3 &>/dev/null; then
        echo "Python is already installed."
    else
        echo "Python is not installed. Installing Python..."
        install_python
    fi
}

# Function to install Python
install_python() {
    echo "Installing Python..."
    sudo apt-get install -y python3 python3-pip
    echo "Python installation completed."
}

# Check if Python is installed
check_python
