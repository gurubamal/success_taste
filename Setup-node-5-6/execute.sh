#RUN on controlnode:
#01#>~/.ssh/known_hosts
#02#ssh-copy-id vagrant@10.0.3.6
#03#ssh-copy-id vagrant@10.0.3.7
#04#ssh-copy-id vagrant@10.0.3.8

./prepare_local.sh

#05#ansible-playbook -i hosts -u vagrant reboot.yml

#06 #ansible -i hosts control  -u vagrant  -a "sudo kubeadm init --apiserver-advertise-address=10.0.3.6 --pod-network-cidr=10.244.0.0/16" |tee init.txt ; echo sudo $(tail -2 init.txt|head -1| cut -d'\' -f1)  $(tail -1 init.txt| cut -d'[' -f1) |tee compute_add.sh


./init_control.sh

ansible-playbook -i hosts -u vagrant kubernetes.yaml
ansible-playbook -i hosts -u vagrant join-compute.yaml
ansible-playbook -i hosts -u vagrant helm.yml
#09 Run on control node  #sudo  kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml 
#https://docs.projectcalico.org/v3.14/manifests/calico.yaml
#kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
