#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Ensure the script runs only on node6
if ! [ "$HOSTNAME" = "node6" ]; then
    exit 0
fi

if [ "$HOSTNAME" = "node6" ]; then
    if ! [ -e /etc/kubernetes/pki/ca.crt ]; then
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

        sudo kubeadm init --apiserver-advertise-address=192.168.58.6 --pod-network-cidr=192.168.0.0/16 | tee init.txt
        if [ $? -ne 0 ]; then
            echo "Error: Failed to initialize Kubernetes with kubeadm."
        fi

        echo sudo $(tail -2 init.txt | head -1 | cut -d'\' -f1) $(tail -1 init.txt | cut -d'[' -f1) | tee -a compute_add.sh
        JOIN_CMD=$(cat compute_add.sh)
        
        echo "if ! [ \$HOSTNAME = node6 ]; then
        if ! [ -e /etc/kubernetes/kubelet.conf ]; then
            sudo rm /etc/containerd/config.toml
            sudo systemctl restart containerd
            sudo systemctl enable containerd
            $JOIN_CMD
        fi
        else
            exit 0
        fi" | tee compute_add.sh
        
        sed 's/node6 = node6/\$HOSTNAME = node6/g' compute_add.sh | tee /vagrant/compute_add.sh
        chmod +x /vagrant/*.sh
    else
        exit 0
    fi
fi

# The following lines are commented out and seem to be alternative commands or notes:
# JOIN_CMD=$(cat compute_add.sh)
# echo "if ! [ "$HOSTNAME" = node6 ]; then
# $JOIN_CMD
# fi" | tee compute_add.sh
# chmod +x compute_add.sh
# sed 's/node6 = node6/\$HOSTNAME = node6/g' compute_add.sh | tee /vagrant/compute_add.sh
# rm join.info
# sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# sudo -i vagrant
# mkdir -p ~/.kube
# sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
# sudo chown vagrant:vagrant /home/vagrant/.kube/config
# kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
