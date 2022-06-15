set -e
set -x


# for floating IP and external connectivity
# choose a small pool from the subnet from ens4
POOL_START=
POOL_END=
GW=
CIDR=

source /root/admin-openrc.sh
neutron net-create --shared --router:external --provider:physical_network provider --provider:network_type flat provider1
neutron subnet-create --name provider1-v4 --ip-version 4 \
   --allocation-pool start=$POOL_START,end=$POOL_END \
   --gateway $GW provider1 $CIDR

# Fix the theme: really fancy stuff
sed -i '/^DEFAULT_THEME/ s/ubuntu/default/g' /usr/share/openstack-dashboard/openstack_dashboard/settings.py
apache2ctl restart
