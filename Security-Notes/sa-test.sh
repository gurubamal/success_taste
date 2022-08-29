#!/bin/bash

#Please set namespace values, NS2 value is optional and can be specified when you want to manage multiple namespaces 

NS1=
NS2=
SA=$NS1-sa
alias g=kubectl

if [ -z "$NS1" ]
then
echo ""
echo ""
echo ""
echo "In order to continue, you must set your namespace NS1 variable first....."
echo ""
echo ""
echo ""
echo ""

exit 1
fi


kubectl create ns $NS1

if ! [ -z "$NS2" ]
then
	kubectl create ns $NS2
fi
mkdir $NS1
cd $NS1
echo "apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SA
  namespace: $NS1
secrets:
  - name: $NS1-secret" > $NS1.sa.yaml

kubectl apply -f $NS1.sa.yaml

echo "apiVersion: v1
kind: Secret
metadata:
  name: $NS1-secret
  namespace: $NS1
  annotations:
    kubernetes.io/service-account.name: $SA
type: kubernetes.io/service-account-token" > $NS1.secret.yaml

kubectl apply -f $NS1.secret.yaml

if ! [ -z "$NS2" ]
then 
cat <<EOF >>$NS2.role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $NS2-adm-role
  namespace: $NS2
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "namespaces", "nodes", "pods/exec", "pods/log"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployment"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["daemonset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["replicaset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["statefulset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["replicationcontroller"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
EOF

kubectl apply -f $NS2.role.yaml
fi

cat <<EOF >> $NS1.role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: $NS1-adm-role
  namespace: $NS1
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "pods/exec", "pods/log"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "update", "list", "watch", "patch", "delete"]
  - apiGroups: ["apps"]
    resources: ["deployment"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["daemonset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["replicaset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["statefulset"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
  - apiGroups: ["apps"]
    resources: ["replicationcontroller"]
    verbs: ["create", "get", "update", "list", "delete", "watch", "patch"]
EOF

kubectl apply -f $NS1.role.yaml




echo "apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $NS1-adm-bind
  namespace: $NS1
subjects:
  - kind: ServiceAccount
    name: $SA
    namespace: $NS1
roleRef:
  kind: Role
  name: $NS1-adm-role
  apiGroup: rbac.authorization.k8s.io" > $NS1-adm.role.bind.yaml


kubectl apply -f $NS1-adm.role.bind.yaml

if ! [ -z "$NS2" ]
then 
echo "apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: $NS2-adm-bind
  namespace: $NS2
subjects:
  - kind: ServiceAccount
    name: $SA
    namespace: $NS1
roleRef:
  kind: Role
  name: $NS2-adm-role
  apiGroup: rbac.authorization.k8s.io" > $NS2-role-bind.yaml

kubectl apply -f $NS2-role-bind.yaml

fi

#echo "apiVersion: v1
#clusters:
#- cluster:
#    certificate-authority-data: 
#    server:
#  name: kubernetes
#contexts:
#- context:
#    cluster: kubernetes
#    user: $SA
#  name: kubernetes-admin@kubernetes
#current-context: kubernetes-admin@kubernetes
#kind: Config
#users:
#- name: $SA
#  user:
#    token: " > $NS1-kubeconf
kubectl config view --flatten --minify|head -n -2 >$NS1-conf
#certinfo=$(kubectl config view --flatten --minify|grep certificate-authority-data)
#sed -i "s/certificate-authority-data\:/$certinfo/g" $NS1-conf

SAtoken=$(kubectl describe secret $NS1-secret -n $NS1|grep token:)
echo \    \ \ $SAtoken >> $NS1-conf

sed -i '10d' $NS1-conf	
USERNAME=$(echo user: $SA)
sed  -i "10i \   \ $USERNAME" $NS1-conf

NAME=$(grep "\- name\:" $NS1-conf)
sed  -i '/\- name\:/d'  $NS1-conf
NEWNAME=$(echo - name: $SA)
sed -i "16i $NEWNAME" $NS1-conf
#sed -i "s/token\:/$$NS1token/g" $NS1-conf
#sed  -i /server:/d  $NS1-conf
#controlip=$(kubectl config view --flatten|grep server:)
#sed  -i "8i \\ \ $controlip" $NS1-conf
echo ""
echo ""
echo ""
echo "your kubeconfig file is $NS1/$NS1-conf for User $NS1-sa"
echo ""
echo ""
echo ""
