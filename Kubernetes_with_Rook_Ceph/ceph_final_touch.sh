cat 03ceph.sh | vagrant ssh node6  -c 'sudo tee 03ceph.sh'
cat 03ceph.sh | vagrant ssh node6  -c 'sudo chmod +x 03ceph.sh'
vagrant ssh node6  -c 'sudo ./03ceph.sh'
