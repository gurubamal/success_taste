#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Clear known hosts file on control node
> ~/.ssh/known_hosts
if [ $? -ne 0 ]; then
  echo "Error: Failed to clear ~/.ssh/known_hosts."
fi

# Copy SSH keys to compute nodes
ssh-copy-id vagrant@10.0.3.6
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy SSH key to 10.0.3.6."
fi

ssh-copy-id vagrant@10.0.3.7
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy SSH key to 10.0.3.7."
fi

ssh-copy-id vagrant@10.0.3.8
if [ $? -ne 0 ]; then
  echo "Error: Failed to copy SSH key to 10.0.3.8."
fi

# Run prepare_local.sh script
./prepare_local.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to run prepare_local.sh."
fi

# Run ansible playbook to reboot nodes
ansible-playbook -i hosts -u vagrant reboot.yml
if [ $? -ne 0 ]; then
  echo "Error: Failed to run ansible playbook for rebooting nodes."
fi

# Initialize Kubernetes on control node and generate join command
ansible -i hosts control -u vagrant -a "sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16" | tee init.txt
if [ $? -ne 0 ]; then
  echo "Error: Failed to initialize Kubernetes on control node."
fi

JOIN_CMD=$(tail -2 init.txt | head -1 | cut -d'\' -f1) $(tail -1 init.txt | cut -d'[' -f1)
echo "sudo $JOIN_CMD" | tee compute_add.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to generate join command."
fi

# Run init_control.sh script
./init_control.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to run init_control.sh."
fi

# Run ansible playbooks to configure Kubernetes cluster
ansible-playbook -i hosts -u vagrant kubernetes.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to run ansible playbook for kubernetes.yaml."
fi

ansible-playbook -i hosts -u vagrant join-compute.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to run ansible playbook for join-compute.yaml."
fi

ansible-playbook -i hosts -u vagrant helm.yml
if [ $? -ne 0 ]; then
  echo "Error: Failed to run ansible playbook for helm.yml."
fi

# Apply network plugin on control node
kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply Flannel network plugin."
fi

# Optionally, apply Calico network plugin
# kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
# if [ $? -ne 0 ]; then
#   echo "Error: Failed to apply Calico network plugin."
# fi
