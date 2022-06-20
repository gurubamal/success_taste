git clone --single-branch --branch release-1.8 https://github.com/rook/rook.git
cd rook/deploy/examples/
kubectl create -f crds.yaml
kubectl create -f common.yaml
kubectl create -f operator.yaml
kubectl get all -n rook-ceph
kubectl get pods -A
kubectl get pods -A
echo "Getting it ready...wait for next 12 Minutes, putting script on sleep...."
sleep 720
kubectl get all -n rook-ceph
kubectl -n rook-ceph get pod
kubectl config set-context --current --namespace rook-ceph
kubectl create -f cluster.yaml
echo "Getting it ready...wait for next 12 Minutes, putting script on sleep...."
sleep 720
kubectl get all -n rook-ceph
kubectl -n rook-ceph get cephcluster
cd ~/
cd rook/deploy/examples
kubectl  apply  -f toolbox.yaml
#kubectl -n rook-ceph exec -it deploy/rook-ceph-tools -- bash
#kubectl get svc -n rook-ceph
#kubectl port-forward service/rook-ceph-mgr-dashboard 8443:8443 -n rook-ceph
#kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
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
  type: NodePort" |tee dashboard-external-https.yaml
kubectl create -f dashboard-external-https.yaml
kubectl -n rook-ceph get service rook-ceph-mgr-dashboard-external-https
kubectl -n rook-ceph get secret rook-ceph-dashboard-password -o jsonpath="{['data']['password']}" | base64 --decode && echo
