#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Ensure the script runs only on nodes other than node6
if ! [ "$HOSTNAME" = "node6" ]; then
    if ! [ -e /etc/kubernetes/kubelet.conf ]; then
        sudo rm /etc/containerd/config.toml
        if [ $? -ne 0 ]; then
            echo "Error: Failed to remove /etc/containerd/config.toml."
        fi

        sudo systemctl restart containerd
        if [ $? -ne 0 ]; then
            echo "Error: Failed to restart containerd."
        fi

        sudo systemctl enable containerd
        if [ $? -ne 0 ]; then
            echo "Error: Failed to enable containerd."
        fi

        sudo kubeadm join 192.168.58.6:6443 --token a874ub.qdhegpl2x4m369sc --discovery-token-ca-cert-hash sha256:97362483b6742c804b092fb68d968eb526d29ddfaecc42339255cf53af79a11c
        if [ $? -ne 0 ]; then
            echo "Error: Failed to join Kubernetes cluster."
        fi
    fi
else
    exit 0
fi
