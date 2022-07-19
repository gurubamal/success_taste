#kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
#kubectl apply -f kubei.yaml
#if [ "$HOSTNAME" = node6 ]; then
#        if ! [ -e /home/vagrant/.kube/config ]
#        then
        sudo mkdir -p /home/vagrant/.kube
	sudo chown vagrant:vagrant /home/vagrant/.kube
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        sudo chown vagrant:vagrant  /home/vagrant/.kube/config
#echo "sleeping for 2 minutes"
#sleep 120
	sudo snap install helm --classic
#        kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
#sudo snap install helm --classic
#       else echo "Now Installing calico Netwrok Plugin......."
#        fi
#fi
#kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml
#kubectl apply -f https://raw.githubusercontent.com/cisco-open/kubei/main/deploy/kubei.yaml
