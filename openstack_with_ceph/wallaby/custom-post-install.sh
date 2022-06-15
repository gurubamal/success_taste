set -e
set -x
# get IP of ens4
# use it to populate pool start, end, gw, cidr
interface=ens4
# Run in subshell to avoid exiting this script
# (dhclient -r $interface; dhclient $interface)
my_ip_pref=`cat /root/$interface | grep "inet" | grep -v "inet6" | awk '{split($2, b, "."); printf("%s.%s.%s.", b[1], b[2], b[3]);}'`

# for floating IP and external connectivity
# choose a small pool from the subnet from ens4
POOL_START=${my_ip_pref}${1:-100}
POOL_END=${my_ip_pref}${2:-120}
GW=${my_ip_pref}1
CIDR=${my_ip_pref}0/24

source /root/admin-openrc.sh
neutron net-create --shared --router:external --provider:physical_network provider --provider:network_type flat provider1
neutron subnet-create --name provider1-v4 --ip-version 4 \
   --allocation-pool start=$POOL_START,end=$POOL_END \
   --gateway $GW provider1 $CIDR

~/files/add-aviadmin-role.sh

# Fix the theme: really fancy stuff
sed -i '/^DEFAULT_THEME/ s/ubuntu/default/g' /usr/share/openstack-dashboard/openstack_dashboard/settings.py
apache2ctl restart
