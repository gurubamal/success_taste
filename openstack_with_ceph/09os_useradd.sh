CloudUser=vagrantu
CLOUDPROJECT=pvagrant
CLOUDROLE=vagrantl
USERPASSWD=vagrant

source  ~/keystonerc
openstack project create --domain default --description "Project for Cloud User $CloudUser" $CLOUDPROJECT
openstack user create --domain default --project $CLOUDPROJECT --password $USERPASSWD $CloudUser
openstack role create $CLOUDROLE
openstack role add --project $CLOUDPROJECT --user $CloudUser $CLOUDROLE
#openstack flavor create --id 0 --vcpus 1 --ram 2048 --disk 10 m1.small
