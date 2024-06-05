#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Clone the rook repository
git clone --single-branch --branch release-1.8 https://github.com/rook/rook.git
if [ $? -ne 0 ]; then
  echo "Error: Failed to clone the rook repository."
  exit 1
fi

# Change to the deploy/examples directory
cd rook/deploy/examples/ || exit

# Create the necessary Kubernetes resources
kubectl create -f crds.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to create crds.yaml."
  exit 1
fi

kubectl create -f common.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to create common.yaml."
  exit 1
fi

kubectl create -f operator.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to create operator.yaml."
  exit 1
fi

# Get all resources in the rook-ceph namespace
kubectl get all -n rook-ceph
kubectl get pods -A

# Wait for services to be ready
echo "Getting it ready...wait for next 12 Minutes, putting script on sleep...."
sleep 720

# Check the status of the resources again
kubectl get all -n rook-ceph
kubectl -n rook-ceph get pod

# Set the current context to the rook-ceph namespace
kubectl config set-context --current --namespace rook-ceph

# Create the Ceph cluster
kubectl create -f cluster.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to create cluster.yaml."
  exit 1
fi

# Wait for the Ceph cluster to be ready
echo "Getting it ready...wait for next 12 Minutes, putting script on sleep...."
sleep 720

# Check the status of the Ceph cluster
kubectl get all -n rook-ceph
kubectl -n rook-ceph get cephcluster

# Apply the toolbox configuration
cd ~/rook/deploy/examples || exit
kubectl apply -f toolbox.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to apply toolbox.yaml."
  exit 1
fi

# Create the dashboard service
echo "apiVersion: v1
kind: Service
metadata:
  name: rook-ceph-mgr-dashboard-external-https
  namespace: rook-ceph
  labels:
    app: rook-ceph-mgr
    rook_cluster: rook-ceph
spec:
  ports:
  - name: dashboard
    port: 8443
    protocol: TCP
    targetPort: 8443
  selector:
    app: rook-ceph-mgr
    rook_cluster: rook-ceph
  sessionAffinity: None
  type: NodePort" | tee dashboard-external-https.yaml

kubectl create -f dashboard-external-https.yaml
if [ $? -ne 0 ]; then
  echo "Error: Failed to create dashboard-external-https.yaml."
  exit 1
fi

# Get the service information
kubectl -n rook-ceph get service rook-ceph-mgr-dashboard-external-https

# Get and display the dashboard password
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
