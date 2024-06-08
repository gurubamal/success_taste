#!/bin/bash

# Remove swap
sudo sed -i '/swap/d' /etc/fstab
sudo swapoff -a

# Ensure bridge network settings
if ! grep -q net.bridge.bridge-nf-call-ip6tables /etc/sysctl.d/kubernetes.conf; then
    sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
fi

# Load necessary kernel modules
if ! grep -q br_netfilter /etc/modules-load.d/containerd.conf; then    
    sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
fi

sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

# Add Docker repository and key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install Docker
sudo apt-get update
sudo apt-get install -y containerd.io docker-ce docker-ce-cli

# Create Docker configuration
sudo mkdir -p /etc/systemd/system/docker.service.d
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Docker
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker

# Configure persistent loading of modules
if ! grep -q overlay /etc/modules-load.d/k8s.conf; then
    sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF
fi

# Reload sysctl settings
sudo sysctl --system

# Add Kubernetes repository and key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl wget vim git gnupg2 software-properties-common

# Remove the specific repository file
sudo rm -f /etc/apt/sources.list.d/home:alvistack.list

# Remove the corresponding GPG key
sudo apt-key del 4BECC97550D0B1FD

# Step 1: Prepare your system
echo "Loading necessary kernel modules..."
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

echo "Applying sysctl params without reboot..."
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Step 2: Install Containerd
echo "Setting up the Docker repository and installing containerd..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y containerd.io

echo "Configuring containerd to use systemd as the cgroup driver..."
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Step 3: Add Kubernetes Repositories
echo "Adding Kubernetes repositories..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.27/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.27/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Step 4: Install Kubernetes Components
echo "Installing Kubernetes components..."
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Kubernetes installation is complete!"
# Configure containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Check containerd status
sudo systemctl status containerd

# Additional configurations for Docker
FILE=/etc/docker/daemon.json
if [ -f "$FILE" ]; then
    echo "$FILE exists."
else
    echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' | sudo tee /etc/docker/daemon.json
    sudo systemctl daemon-reload && sudo systemctl restart kubelet
fi

if ! grep -q native.cgroupdriver=systemd /etc/systemd/system/multi-user.target.wants/docker.service; then
    sudo systemctl stop docker
    sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
    sudo systemctl daemon-reload
    sudo systemctl restart docker
    sudo systemctl restart kubelet
fi

# Mask swap partition (only if it exists)
if [ -e /dev/sda3.swap ]; then
    sudo systemctl mask "dev-sda3.swap"
fi


###
# Variables
KUBELET_CONFIG_DIR="/etc/systemd/system/kubelet.service.d"
KUBELET_SERVICE_FILE="${KUBELET_CONFIG_DIR}/10-kubeadm.conf"
GRUB_CONFIG_FILE="/etc/default/grub"
GRUB_CONFIG_BACKUP_FILE="${GRUB_CONFIG_FILE}.bak"

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if a line exists in a file
line_exists_in_file() {
    grep -qF "$1" "$2"
}

# Ensure the necessary directories exist
sudo mkdir -p "$KUBELET_CONFIG_DIR"

# Check and update the kubelet cgroup driver configuration
echo "Checking kubelet cgroup driver configuration..."
if ! line_exists_in_file 'Environment="KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd"' "$KUBELET_SERVICE_FILE"; then
    echo "Configuring kubelet to use systemd cgroup driver..."
    sudo tee "$KUBELET_SERVICE_FILE" > /dev/null <<EOF
[Service]
Environment="KUBELET_KUBEADM_ARGS=--cgroup-driver=systemd"
ExecStart=
ExecStart=/usr/local/bin/kubelet \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF
else
    echo "Kubelet cgroup driver configuration is already set to systemd."
fi

# Verify cgroups are enabled
echo "Verifying cgroups..."
REQUIRED_CGROUPS=("cpu" "memory" "cpuset")
MISSING_CGROUPS=()

for CGROUP in "${REQUIRED_CGROUPS[@]}"; do
    if ! lssubsys -a | grep -q "$CGROUP"; then
        MISSING_CGROUPS+=("$CGROUP")
    fi
done

if [ ${#MISSING_CGROUPS[@]} -eq 0 ]; then
    echo "All required cgroups are enabled."
else
    echo "Missing cgroups detected: ${MISSING_CGROUPS[*]}"
    echo "Checking if GRUB configuration already updated for cgroups..."

    if ! line_exists_in_file 'cgroup_enable=memory' "$GRUB_CONFIG_FILE"; then
        echo "Updating GRUB configuration to enable cgroups..."

        # Backup existing GRUB configuration if not already backed up
        if [ ! -f "$GRUB_CONFIG_BACKUP_FILE" ]; then
            sudo cp "$GRUB_CONFIG_FILE" "$GRUB_CONFIG_BACKUP_FILE"
        fi

        # Update GRUB configuration to enable cgroups
        sudo sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory swapaccount=1"/' "$GRUB_CONFIG_FILE"

        # Update GRUB and reboot
        sudo update-grub
        echo "System needs to reboot to apply cgroup changes."
        sudo reboot
    else
        echo "GRUB configuration already updated for cgroups."
    fi
fi

