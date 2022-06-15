set -x
set -e
interface="ens4"
ip_pref=`cat /root/$interface | grep "inet" | grep -v "inet6" | awk '{split($2, b, "."); printf("%s.%s.", b[1], b[2]);}'`
cidr=${ip_pref}0.0/16

my_mac=`cat /root/$interface | grep "ether" | awk '{print $2;}'`
if [ -z "$my_mac" ]; then
    echo "Can't find mac!"
    exit
fi

# Resolve openstack-controller
#sed -i "/nameserver/d" /etc/resolv.conf
#sed -i "/search/d" /etc/resolv.conf
#echo "nameserver 10.10.0.100" >> /etc/resolv.conf
#echo "search avi.local" >> /etc/resolv.conf
echo "10.50.62.22     openstack-controller.avi.local" >> /etc/hosts

# Clean up any OS_ variables set
for i in `env | grep OS_ | cut -d'=' -f1`;do unset $i;done

# figure out the port-id from lab credentials
source ./lab_openrc.sh

port_id=`neutron port-list | grep "$my_mac" | awk '{print $2;}'`
qrouters=`ip netns list | grep qrouter | cut -f 1 -d ' '`
aaplist=""
for qr in $qrouters; do
    if=`ip netns exec $qr ifconfig | grep qg- | cut -d':' -f1`
    mac=`ip netns exec $qr ifconfig $if | grep ether | awk '{print $2}'`
    aaplist="$aaplist mac_address=$mac,ip_address=$cidr"
done

neutron port-update $port_id  --allowed-address-pairs type=dict list=true $aaplist 
