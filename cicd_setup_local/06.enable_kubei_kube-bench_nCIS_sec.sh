#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Apply Kubei YAML configuration
kubectl apply -f kubei.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply kubei.yaml."
fi

# Clone the kube-bench repository and apply configurations
git clone https://github.com/aquasecurity/kube-bench.git
if [ $? -ne 0 ]; then
  echo "Error: Failed to clone kube-bench repository."
else
  cd kube-bench/
  kubectl apply -f job-node.yaml
  if [ $? -ne 0 ]; then
    echo "Error: Failed to apply job-node.yaml."
  fi
  kubectl apply -f job-master.yaml
  if [ $? -ne 0 ]; then
    echo "Error: Failed to apply job-master.yaml."
  fi
  kubectl get pods
  if [ $? -ne 0 ]; then
    echo "Error: Failed to get pods."
  fi
fi

# Optionally log output from kube-bench (commented out in the original)
# kubectl logs "master" | tee master.audit.report
# kubectl logs "node" | tee node.audit.report

# Install and configure Ubuntu Advantage tools
sudo apt-cache policy ubuntu-advantage-tools
if [ $? -ne 0 ]; then
  echo "Error: Failed to check policy for ubuntu-advantage-tools."
fi
sudo apt-cache policy ubuntu-advantage-tools
if [ $? -ne 0 ]; then
  echo "Error: Failed to check policy for ubuntu-advantage-tools."
fi

sudo apt install ubuntu-advantage-tools usg -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to install ubuntu-advantage-tools and usg."
fi

sudo ua version
if [ $? -ne 0 ]; then
  echo "Error: Failed to get Ubuntu Advantage version."
fi

sudo ua status
if [ $? -ne 0 ]; then
  echo "Error: Failed to get Ubuntu Advantage status."
fi

sudo ua attach C148smEmHdTdUDj2LfUkFKCFQii34g
if [ $? -ne 0 ]; then
  echo "Error: Failed to attach Ubuntu Advantage token."
fi

sudo ua enable usg
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable usg."
fi

sudo apt install libopenscap8 -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to install libopenscap8."
fi

# Optionally run USG audit (commented out in the original)
# sudo usg audit level2_server
