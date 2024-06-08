#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Ensure the script runs only on node6
if [ "$HOSTNAME" = "node6" ]; then
    if ! [ -e /home/vagrant/.kube/config ]; then
        # Create .kube directory for vagrant and set ownership
        sudo mkdir -p /home/vagrant/.kube
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create /home/vagrant/.kube directory."
        fi

        sudo chown vagrant:vagrant /home/vagrant/.kube
        if [ $? -ne 0 ]; then
            echo "Error: Failed to change ownership of /home/vagrant/.kube directory."
        fi

        # Create .kube directory for root
        sudo mkdir -p /root/.kube
        if [ $? -ne 0 ]; then
            echo "Error: Failed to create /root/.kube directory."
        fi

        # Copy admin.conf to .kube directories and set ownership
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        if [ $? -ne 0 ]; then
            echo "Error: Failed to copy admin.conf to /home/vagrant/.kube/config."
        fi

        sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
        if [ $? -ne 0 ]; then
            echo "Error: Failed to copy admin.conf to /root/.kube/config."
        fi

        sudo chown vagrant:vagrant /home/vagrant/.kube/config
        if [ $? -ne 0 ]; then
            echo "Error: Failed to change ownership of /home/vagrant/.kube/config."
        fi

        # Sleep for 2 minutes
        sleep 120

        # Apply Calico network plugin
        FILE=/vagrant/scripts/calico.yaml
        
        if [ ! -f "$FILE" ]; then
            echo "$FILE does not exist. Downloading..."
            wget https://raw.githubusercontent.com/projectcalico/calico/master/manifests/calico.yaml -O "$FILE"
        else
            echo "$FILE already exists."
        fi

        kubectl apply -f /vagrant/scripts/calico.yaml
        if [ $? -ne 0 ]; then
            echo "Error: Failed to apply Calico network plugin."
        fi

        # Update bashrc for root
        cat /vagrant/bashrc.local | tr -d '\r' | sudo tee /root/.bashrc
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update /root/.bashrc."
        fi

        sudo chmod +x /root/.bashrc
        if [ $? -ne 0 ]; then
            echo "Error: Failed to set execute permission on /root/.bashrc."
        fi

        # Update bashrc for vagrant
        cat /vagrant/bashrc.local | tr -d '\r' | tee /home/vagrant/.bashrc
        if [ $? -ne 0 ]; then
            echo "Error: Failed to update /home/vagrant/.bashrc."
        fi

        chmod +x /home/vagrant/.bashrc
        if [ $? -ne 0 ]; then
            echo "Error: Failed to set execute permission on /home/vagrant/.bashrc."
        fi

        # Uncomment and modify the following lines if needed
        # sudo kubectl apply -f /vagrant/tigera-operator.yaml
        # sudo kubectl apply -f /vagrant/custom-resources.yaml
        # kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
        # kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
    fi
fi
