vagrant ssh node6  -c '/vagrant/05_post_join_control.sh'
vagrant ssh node6  -c 'kubectl apply -f https://projectcalico.docs.tigera.io/manifests/calico.yaml'
