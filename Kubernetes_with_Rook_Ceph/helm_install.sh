#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Download Helm installation script
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
if [ $? -ne 0 ]; then
  echo "Error: Failed to download Helm installation script."
  exit 1
fi

# Make the Helm installation script executable
chmod 700 get_helm.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to make Helm installation script executable."
  exit 1
fi

# Run the Helm installation script
./get_helm.sh
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Helm."
  exit 1
fi
