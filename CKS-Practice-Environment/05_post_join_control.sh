#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Create .kube directory for vagrant and set ownership
sudo mkdir -p /home/vagrant/.kube
if [ $? -ne 0 ]; then
  echo "Error: Failed to create /home/vagrant/.kube directory."
fi

sudo chown vagrant:vagrant /home/vagrant/.kube
if [ $? -ne 0 ]; then
  echo "Error: Failed to change ownership of /home/vagrant/.kube directory."
fi

# Copy admin.conf to .kube directory and set ownership
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

# The following lines are commented out and seem to be alternative commands or notes:
# kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# kubectl apply -f kubei.yaml
# if [ "$HOSTNAME" = node6 ]; then
#         if ! [ -e /home/vagrant/.kube/config ]; then
#         sudo mkdir -p /home/vagrant/.kube
#         sudo chown vagrant:vagrant /home/vagrant/.kube
#         sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
#         sudo chown vagrant:vagrant /home/vagrant/.kube/config
#         echo "sleeping for 2 minutes"
#         sleep 120
#         sudo snap install helm --classic
#         kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
#         else echo "Now Installing calico Netwrok Plugin......."
#         fi
# fi
# kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
# kubectl apply -f https://raw.githubusercontent.com/cisco-open/kubei/main/deploy/kubei.yaml
