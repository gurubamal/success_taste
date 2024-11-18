#!/bin/bash

# Define variables
METALLB_DEPLOYMENT_URL="https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml"
CERT_MANAGER_VERSION="v1.16.0"
IP_RANGE="10.200.1.80-10.200.1.90"
NAMESPACE="metallb-system"

echo "Deleting existing MetalLB deployment..."

# Delete existing MetalLB components
kubectl delete --ignore-not-found -f $METALLB_DEPLOYMENT_URL

# Delete any existing ValidatingWebhookConfiguration
kubectl delete validatingwebhookconfiguration metallb-webhook-configuration --ignore-not-found

# Delete the MetalLB namespace to clean up any leftover resources
kubectl delete namespace $NAMESPACE --ignore-not-found

echo "Waiting for the MetalLB namespace to terminate..."

while kubectl get namespace $NAMESPACE >/dev/null 2>&1; do
  sleep 1
done

echo "Modifying kube-proxy configmap to enable strictARP..."

# Modify kube-proxy configmap to set strictARP to true
kubectl get configmap kube-proxy -n kube-system -o yaml | \
sed -e "s/strictARP: false/strictARP: true/" | \
kubectl apply -f - -n kube-system

echo "Installing Cert-Manager..."

# Install Cert-Manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/$CERT_MANAGER_VERSION/cert-manager.yaml

echo "Waiting for Cert-Manager pods to be ready..."
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=180s

echo "Creating MetalLB namespace..."

# Create the MetalLB namespace
kubectl create namespace $NAMESPACE

echo "Creating memberlist secret..."

# Create the memberlist secret required by MetalLB
kubectl create secret generic memberlist \
  -n $NAMESPACE \
  --from-literal=secretkey="$(openssl rand -base64 128)"

echo "Creating self-signed Issuer for MetalLB webhook..."

# Create a self-signed Issuer in the metallb-system namespace
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: metallb-selfsigned-issuer
  namespace: $NAMESPACE
spec:
  selfSigned: {}
EOF

echo "Installing MetalLB..."

# Install MetalLB with Webhooks Enabled
kubectl apply -f $METALLB_DEPLOYMENT_URL

echo "Waiting for MetalLB CRDs to be established..."

# Wait for the CRDs to be established before creating the Certificate
sleep 10

echo "Creating Certificate resource for MetalLB webhook..."

# Create the Certificate resource for the webhook
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: metallb-webhook-cert
  namespace: $NAMESPACE
spec:
  secretName: metallb-webhook-cert
  duration: 8760h # One year
  renewBefore: 360h # 15 days
  subject:
    organizations:
      - metallb
  commonName: metallb-webhook.$NAMESPACE.svc
  dnsNames:
    - metallb-webhook.$NAMESPACE.svc
    - metallb-webhook.$NAMESPACE.svc.cluster.local
  issuerRef:
    name: metallb-selfsigned-issuer
    kind: Issuer
    group: cert-manager.io
EOF

echo "Waiting for the metallb-webhook-cert certificate to be ready..."

kubectl wait --namespace $NAMESPACE \
  --for=condition=Ready certificate/metallb-webhook-cert \
  --timeout=180s

echo "Restarting MetalLB controller to pick up the new certificate..."

kubectl rollout restart deployment/controller -n $NAMESPACE

echo "Waiting for MetalLB controller and speaker pods to be ready..."

kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app=metallb,component=controller \
  --timeout=180s

kubectl wait --namespace $NAMESPACE \
  --for=condition=ready pod \
  --selector=app=metallb,component=speaker \
  --timeout=180s

echo "Configuring MetalLB with IP address pool..."

# Create IPAddressPool resource
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: my-ip-pool
  namespace: $NAMESPACE
spec:
  addresses:
  - $IP_RANGE
EOF

# Create L2Advertisement resource
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: my-l2-advertisement
  namespace: $NAMESPACE
spec:
  ipAddressPools:
  - my-ip-pool
EOF

echo "MetalLB installation and configuration complete."
