#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Ensure the script runs only on node4
if [ "$HOSTNAME" = "node4" ]; then
    if ! [ -e /home/vagrant/.kube/config ]; then
        # Create .kube directory for vagrant and set ownership
        sudo mkdir -p /home/vagrant/.kube
        if [ $? -eq 0 ]; then
            echo "Successfully created /home/vagrant/.kube directory."
        else
            echo "Error: Failed to create /home/vagrant/.kube directory."
        fi

        sudo chown vagrant:vagrant /home/vagrant/.kube
        if [ $? -eq 0 ]; then
            echo "Successfully changed ownership of /home/vagrant/.kube directory."
        else
            echo "Error: Failed to change ownership of /home/vagrant/.kube directory."
        fi

        # Create .kube directory for root
        sudo mkdir -p /root/.kube
        if [ $? -eq 0 ]; then
            echo "Successfully created /root/.kube directory."
        else
            echo "Error: Failed to create /root/.kube directory."
        fi

        # Copy admin.conf to .kube directories and set ownership
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        if [ $? -eq 0 ]; then
            echo "Successfully copied admin.conf to /home/vagrant/.kube/config."
        else
            echo "Error: Failed to copy admin.conf to /home/vagrant/.kube/config."
        fi

        sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
        if [ $? -eq 0 ]; then
            echo "Successfully copied admin.conf to /root/.kube/config."
        else
            echo "Error: Failed to copy admin.conf to /root/.kube/config."
        fi

        sudo chown vagrant:vagrant /home/vagrant/.kube/config
        if [ $? -eq 0 ]; then
            echo "Successfully changed ownership of /home/vagrant/.kube/config."
        else
            echo "Error: Failed to change ownership of /home/vagrant/.kube/config."
        fi

        # Sleep for 2 minutes
        sleep 120

        # Apply Calico network plugin
        #FILE=/vagrant/scripts/calico.yaml

        #if [ ! -f "$FILE" ]; then
         #   echo "$FILE does not exist. Downloading..."
         #   wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O "$FILE"
        #else
        #    echo "$FILE already exists."
        #fi

        #kubectl apply -f /vagrant/scripts/calico.yaml
        #if [ $? -eq 0 ]; then
        #    echo "Successfully applied Calico network plugin."
        #else
        #    echo "Error: Failed to apply Calico network plugin."
        #fi

        # Update bashrc for root
        cat /vagrant/bashrc.local | tr -d '\r' | sudo tee /root/.bashrc
        if [ $? -eq 0 ]; then
            echo "Successfully updated /root/.bashrc."
        else
            echo "Error: Failed to update /root/.bashrc."
        fi

        sudo chmod +x /root/.bashrc
        if [ $? -eq 0 ]; then
            echo "Successfully set execute permission on /root/.bashrc."
        else
            echo "Error: Failed to set execute permission on /root/.bashrc."
        fi

        # Update bashrc for vagrant
        cat /vagrant/bashrc.local | tr -d '\r' | tee /home/vagrant/.bashrc
        if [ $? -eq 0 ]; then
            echo "Successfully updated /home/vagrant/.bashrc."
        else
            echo "Error: Failed to update /home/vagrant/.bashrc."
        fi

        chmod +x /home/vagrant/.bashrc
        if [ $? -eq 0 ]; then
            echo "Successfully set execute permission on /home/vagrant/.bashrc."
        else
            echo "Error: Failed to set execute permission on /home/vagrant/.bashrc."
        fi
    else
        echo "/home/vagrant/.kube/config already exists. Skipping setup."
    fi
else
    echo "This script is only meant to be run on node4. Exiting."
    exit 0
fi

# Install Helm
sudo apt update
sudo apt install snapd -y
sudo snap install helm --classic
if [ $? -eq 0 ]; then
    echo "Successfully installed Helm."
else
    echo "Error: Failed to install Helm."
fi
sudo kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s-1.11.yaml"
if [ $? -ne 0 ]; then
            wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O /vagrant/scripts/calico.yaml
            sudo kubectl apply -f /vagrant/scripts/calico.yaml
fi
