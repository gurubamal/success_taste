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

# Create the systemd service file
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


MARKER_FILE="/var/log/my_script_executed"

if [ -f "$MARKER_FILE" ]; then
    echo "Script has already been executed. Exiting..."
    exit 0
fi


apt-get install linux-headers-$(uname -r) build-essential dkms

echo "Removing old repository configurations..."
sudo rm -rf /etc/apt/sources.list.d/*

echo "Resetting sources list..."
sudo tee /etc/apt/sources.list <<EOF
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
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo apt-get update -y
apt-get install linux-headers-$(uname -r) build-essential dkms

# Create the marker file to indicate that the script has been executed
sudo touch "$MARKER_FILE"

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
