COUNT=2

source  ~/keystonerc
openstack flavor list
openstack network list
openstack security group create secgroup01
openstack security group list

ssh-keygen -q -N "" -f ~/.ssh/id_rsa$COUNT

openstack keypair create --public-key ~/.ssh/id_rsa$COUNT.pub  mykey
openstack keypair list
netID=$(openstack network list | grep sharednet1 | awk '{ print $2 }')
openstack server create --flavor m1.small --image Ubuntu2004 --security-group secgroup01 --nic net-id=$netID --key-name mykey Ubuntu-2004
openstack server list
openstack security group rule create --protocol icmp --ingress secgroup01
openstack security group rule create --protocol tcp --dst-port 22:22 secgroup01
openstack security group rule list secgroup01
openstack server list
openstack console url show Ubuntu-2004
openstack server stop Ubuntu-2004


#Enable the setting for Nested KVM
#echo 'options kvm_intel nested=1' >> /etc/modprobe.d/qemu-system-x86.conf
