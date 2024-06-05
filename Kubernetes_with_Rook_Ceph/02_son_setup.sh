#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Update package lists
sudo apt-get update
if [ $? -ne 0 ]; then
  echo "Error: Failed to update package list."
fi

# Uncomment to install Docker and Kubernetes packages
# sudo apt-get install -y docker-ce kubelet kubeadm kubectl
# if [ $? -ne 0 ]; then
#   echo "Error: Failed to install Docker and Kubernetes packages."
# fi

# Configure sysctl
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
if [ $? -ne 0 ]; then
  echo "Error: Failed to update /etc/sysctl.conf."
fi

sudo sysctl -p
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply sysctl settings."
fi

# Disable swap
sudo swapoff /swap.img
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable swap."
fi

sudo sed -i 's/\/swap.img/#\/swap.img/g' /etc/fstab
if [ $? -ne 0 ]; then
  echo "Error: Failed to comment out swap.img in /etc/fstab."
fi

# Uncomment the following block to configure Docker daemon if needed
# FILE=/etc/docker/daemon.json
# if test -f "$FILE"; then
#   echo "$FILE exists."
# else
#   echo '{
#   "exec-opts": ["native.cgroupdriver=systemd"]
# }' | sudo tee /etc/docker/daemon.json
#   if [ $? -ne 0 ]; then
#     echo "Error: Failed to create /etc/docker/daemon.json."
#   fi
#   sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
#   if [ $? -ne 0 ]; then
#     echo "Error: Failed to reload systemd and restart Docker and Kubelet."
#   fi
# fi

# Uncomment the following block to ensure Docker uses systemd as the cgroup driver if needed
# if ! grep -q "native.cgroupdriver=systemd" /etc/systemd/system/multi-user.target.wants/docker.service; then
#   sudo systemctl stop docker
#   sudo sed -i 's/containerd.sock/containerd.sock --exec-opt native.cgroupdriver=systemd/g' /etc/systemd/system/multi-user.target.wants/docker.service
#   if [ $? -ne 0 ]; then
#     echo "Error: Failed to configure Docker to use systemd as the cgroup driver."
#   fi
#   sudo systemctl daemon-reload && sudo systemctl restart docker && sudo systemctl restart kubelet
#   if [ $? -ne 0 ]; then
#     echo "Error: Failed to reload systemd and restart Docker and Kubelet after configuration."
#   fi
# fi
