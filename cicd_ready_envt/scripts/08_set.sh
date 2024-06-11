#!/bin/bash

# Ensure the script runs only on node4
if [ "$HOSTNAME" != "node4" ]; then
    echo "This script is only meant to be run on node4. Exiting."
    exit 0
fi

# Function to check if kubelet is running, identify its ports, and kill the process
check_and_kill_kubelet() {
    if pgrep -x "kubelet" > /dev/null; then
        echo "Kubelet is running. Checking the ports it is using..."
        sudo lsof -i -P -n | grep kubelet | grep LISTEN
        PID=$(pgrep -x "kubelet")
        if [ -n "$PID" ]; then
            echo "Killing kubelet process with PID $PID..."
            sudo kill -9 $PID
            echo "Process $PID killed."
        else
            echo "No process found for kubelet."
        fi
    else
        echo "Kubelet is not running."
    fi
}

# Function to stop kubelet service
stop_kubelet_service() {
    echo "Stopping kubelet service..."
    sudo systemctl stop kubelet
    echo "Kubelet service stopped."
}

# Function to install required packages if not already installed
install_packages() {
    echo "Updating package list..."
    sudo apt-get update
    for pkg in socat conntrack; do
        if ! dpkg -s $pkg &> /dev/null; then
            echo "Installing $pkg..."
            sudo apt-get install -y $pkg
        else
            echo "$pkg is already installed."
        fi
    done
}

# Function to install crictl if not already installed
install_crictl() {
    local version="v1.24.1"
    if ! command -v crictl &> /dev/null; then
        echo "Installing crictl version $version..."
        wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${version}/crictl-${version}-linux-amd64.tar.gz
        sudo tar zxvf crictl-${version}-linux-amd64.tar.gz -C /usr/local/bin
        rm crictl-${version}-linux-amd64.tar.gz
    else
        echo "crictl is already installed."
    fi
}

# Function to verify installations
verify_installations() {
    echo "Verifying installations..."
    for cmd in socat conntrack crictl; do
        if ! command -v $cmd &> /dev/null; then
            echo "$cmd installation failed."
        else
            echo "$cmd installed successfully."
        fi
    done
}

# Main script execution
install_packages
install_crictl
verify_installations
if [ ! -e /etc/kubernetes/pki/ca.crt ]; then
    echo "Pulling images..... it will take few minutes........"
    timeout 188 sudo kubeadm config images pull --image-repository registry.aliyuncs.com/google_containers 2>/dev/null
    check_and_kill_kubelet

    if [ -e /etc/containerd/config.toml ]; then
        echo "Removing containerd config file..."
        sudo rm /etc/containerd/config.toml
    else
        echo "/etc/containerd/config.toml does not exist. Skipping removal."
    fi

    echo "Restarting containerd..."
    sudo systemctl restart containerd
    sudo systemctl enable containerd

    # Define variables
    POD_CIDR=10.244.0.0/16
    SERVICE_CIDR=10.96.0.0/16
    PRIMARY_IP=192.168.56.4

    # Disable swap
    sudo swapoff -a

    # Stop kubelet service just before initialization
    stop_kubelet_service

    # Check if the kubelet is running
    echo "Checking kubelet status..."
    sudo systemctl status kubelet

    # Check kubelet logs
    echo "Fetching kubelet logs..."
    sudo journalctl -xeu kubelet

    # Initialize Kubernetes control plane and save output to init.txt
    echo "Initializing Kubernetes control plane..."
    sudo kubeadm init --control-plane-endpoint=$PRIMARY_IP --pod-network-cidr=$POD_CIDR --service-cidr=$SERVICE_CIDR --apiserver-advertise-address=$PRIMARY_IP --cri-socket=unix:///run/containerd/containerd.sock | tee init.txt

    # Generate the join command for compute nodes
if [ $? -ne 0 ]; then
            echo "Error: Failed to initialize Kubernetes with kubeadm."
        fi

        echo sudo $(tail -2 init.txt | head -1 | cut -d'\' -f1) $(tail -1 init.txt | cut -d'[' -f1) | tee -a compute_add.sh
        JOIN_CMD=$(cat compute_add.sh)

        echo "if ! [ \$HOSTNAME = node4 ]; then
        if ! [ -e /etc/kubernetes/kubelet.conf ]; then
            sudo rm /etc/containerd/config.toml
            sudo systemctl restart containerd
            sudo systemctl enable containerd
            sudo swapoff -a
            $JOIN_CMD
        fi
        else
            exit 0
        fi" | tee compute_add.sh

        sed 's/node4 = node4/\$HOSTNAME = node4/g' compute_add.sh | tee /vagrant/scripts/compute_add.sh
        chmod +x /vagrant/scripts/*.sh
else
    echo "/etc/kubernetes/pki/ca.crt already exists. Skipping setup."
fi

sleep 60
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"

