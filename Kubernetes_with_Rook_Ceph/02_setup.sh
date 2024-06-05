#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker GPG key."
fi

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Docker repository."
fi

# Add Kubernetes GPG key and repository
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes GPG key."
fi

cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
if [ $? -ne 0 ]; then
  echo "Error: Failed to add Kubernetes repository to sources list."
fi

# Update package lists and install Docker and Kubernetes packages
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

sudo apt-get install -y docker-ce kubelet kubeadm kubectl
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Docker and Kubernetes packages."
fi

# Configure sysctl
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
if [ $? -ne 0 ]; then
  echo "Error: Failed to update /etc/sysctl.conf."
fi

sudo sysctl -p
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply sysctl settings."
fi

# Add vagrant user to docker group
sudo usermod -aG docker vagrant
if [ $? -ne 0 ]; then
  echo "Error: Failed to add vagrant user to docker group."
fi

# Disable swap
sudo swapoff -a
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable swap."
fi

sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
if [ $? -ne 0 ]; then
  echo "Error: Failed to comment out swap.img in /etc/fstab."
fi

# Load required kernel modules
echo overlay br_netfilter | sudo tee -a /etc/modules-load.d/containerd.conf
if [ $? -ne 0 ]; then
  echo "Error: Failed to configure kernel modules."
fi

# Configure Docker daemon
FILE=/etc/docker/daemon.json
if test -f "$FILE"; then
  echo "$FILE exists."
else
  echo '{
  "exec-opts": ["native.cgroupdriver=systemd"]
}' | sudo tee /etc/docker/daemon.json
  if [ $? -ne 0 ]; then
    echo "Error: Failed to create /etc/docker/daemon.json."
  fi
  sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd and restart Docker and Kubelet."
  fi
fi

if ! grep -q "native.cgroupdriver=systemd" /etc/systemd/system/multi-user.target.wants/docker.service; then
  sudo systemctl stop docker
  sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
  if [ $? -ne 0 ]; then
    echo "Error: Failed to configure Docker to use systemd as the cgroup driver."
  fi
  sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
  if [ $? -ne 0 ]; then
    echo "Error: Failed to reload systemd and restart Docker and Kubelet after configuration."
  fi
fi
