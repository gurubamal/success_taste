#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Clone istio-fleetman repository
git clone https://github.com/DickChesterwood/istio-fleetman.git
if [ $? -ne 0 ]; then
  echo "Error: Failed to clone istio-fleetman repository."
fi

# Apply Istio initialization configuration
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/1-istio-init.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply 1-istio-init.yaml."
fi

# Wait for services to come up
echo "Wait for 3 minutes! Services are coming up..."
sleep 180

# Apply Istio Minikube configuration
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/2-istio-minikube.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply 2-istio-minikube.yaml."
fi

# Set label in default namespace for Istio injection
kubectl label namespace default istio-injection=enabled
if [ $? -ne 0 ]; then
  echo "Error: Failed to label default namespace for Istio injection."
fi

# Wait for services to come up
echo "Wait for 3 minutes! Services are coming up..."
sleep 180

# Apply Kiali secret configuration
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/3-kiali-secret.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply 3-kiali-secret.yaml."
fi

# Apply full stack application configuration
kubectl apply -f /home/vagrant/istio-fleetman/_course_files/warmup-exercise/4-application-full-stack.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply 4-application-full-stack.yaml."
fi

# Display service URLs
echo "Kiali services will be running at http://192.168.58.6:31000/"
echo "Fleet management app will be available at http://192.168.58.6:30080/"
