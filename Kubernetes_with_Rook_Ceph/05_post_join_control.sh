#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Create .kube directory for vagrant user if not exists and copy the Kubernetes admin config
sudo mkdir -p /home/vagrant/.kube
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /home/vagrant/.kube directory."
fi

sudo chown vagrant:vagrant /home/vagrant/.kube
if [ $? -ne 0 ]; then
  echo "Error: Failed to change ownership of /home/vagrant/.kube directory."
fi

sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy admin.conf to /home/vagrant/.kube/config."
fi

sudo chown vagrant:vagrant /home/vagrant/.kube/config
if [ $? -ne 0 ]; then
  echo "Error: Failed to change ownership of /home/vagrant/.kube/config."
fi

# Install Helm
sudo snap install helm --classic
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Helm."
fi

# Uncomment the following lines to apply network plugin and other configurations
# kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
# sudo snap install helm --classic
# else echo "Now Installing calico Network Plugin......."
# fi
# fi
# kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
# kubectl apply -f https://raw.githubusercontent.com/cisco-open/kubei/main/deploy/kubei.yaml
