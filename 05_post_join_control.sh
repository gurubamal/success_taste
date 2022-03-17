if [ "$HOSTNAME" = node6 ]; then
mkdir -p ~/.kube
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config
sudo chown vagrant:vagrant  /home/vagrant/.kube/config
kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
sudo snap install helm --classic
#kubectl apply -f kubei.yaml
fi
#kubectl apply -f https://raw.githubusercontent.com/cisco-open/kubei/main/deploy/kubei.yaml
