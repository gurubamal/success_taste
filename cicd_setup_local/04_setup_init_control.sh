#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Ensure the script runs only on node6
if ! [ "$HOSTNAME" = "node6" ]; then
    exit 0
fi

# Check if the hostname is node6
if [ "$HOSTNAME" = "node6" ]; then
    if ! [ -e /etc/kubernetes/pki/ca.crt ]; then
        sudo rm /etc/containerd/config.toml
        sudo systemctl restart containerd
        sudo systemctl enable containerd

        sudo kubeadm init --apiserver-advertise-address=192.168.58.6 --pod-network-cidr=192.168.0.0/16 | tee init.txt
        if [ $? -ne 0 ]; then
            echo "Error: kubeadm init failed."
            exit 1
        fi

        if [ ! -s init.txt ]; then
            echo "Error: init.txt is empty."
            exit 1
        fi

        JOIN_CMD=$(tail -2 init.txt | head -1 | cut -d'\' -f1)
        if [ -z "$JOIN_CMD" ]; then
            echo "Error: JOIN_CMD is empty."
            exit 1
        fi

        echo "sudo $JOIN_CMD $(tail -1 init.txt | cut -d'[' -f1)" | tee compute_add.sh

        echo "if ! [ \$HOSTNAME = node6 ]; then
        if ! [ -e /etc/kubernetes/kubelet.conf ]; then
            sudo rm /etc/containerd/config.toml
            sudo systemctl restart containerd
            sudo systemctl enable containerd
            $JOIN_CMD
        fi
        else
            exit 0
        fi" | tee -a compute_add.sh

        sed 's/node6 = node6/\$HOSTNAME = node6/g' compute_add.sh | tee /vagrant/compute_add.sh
        chmod +x /vagrant/*.sh
    else
        exit 0
    fi
fi
