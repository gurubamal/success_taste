if [ "$HOSTNAME" = node6 ]; then
        if ! [ -e /home/vagrant/.kube/config ]
        then
        sudo mkdir -p /home/vagrant/.kube
        sudo chown vagrant:vagrant /home/vagrant/.kube
        sudo mkdir -p /root/.kube
        sudo cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
        sudo cp -i /etc/kubernetes/admin.conf /root/.kube/config
        sudo chown vagrant:vagrant  /home/vagrant/.kube/config
	sleep 120
	kubectl apply -f /vagrant/calico.yaml
	#sudo kubectl apply -f /vagrant/tigera-operator.yaml
	#sudo kubectl apply -f /vagrant/custom-resources.yaml
        #kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
        #kubectl create -f https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml
        fi
fi
