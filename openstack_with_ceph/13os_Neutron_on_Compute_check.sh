ETH1=eth1
controller_ip=$(grep controller  /etc/hosts|awk '{print $1}')
controller=controller
SUBNET1=192.168.58
MYIP=$(hostname -I|awk '{print $NF}')
CONTROLNODEIP=$(grep controller  /etc/hosts|awk '{print $1}')

source  ~/keystonerc
sudo apt -y install neutron-common neutron-plugin-ml2 neutron-linuxbridge-agent
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org

echo "# create new
[DEFAULT]
core_plugin = ml2
service_plugins = router
auth_strategy = keystone
state_path = /var/lib/neutron
allow_overlapping_ips = True
# RabbitMQ connection info
transport_url = rabbit://openstack:password@10.0.0.30

[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

# Keystone auth info
[keystone_authtoken]
www_authenticate_uri = http://10.0.0.30:5000
auth_url = http://10.0.0.30:5000
memcached_servers = 10.0.0.30:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = servicepassword

[oslo_concurrency]
lock_path = $state_path/lock" |sudo tee /etc/neutron/neutron.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/neutron/neutron.conf
sudo chmod 640 /etc/neutron/neutron.conf
sudo chgrp neutron /etc/neutron/neutron.conf


sudo sed -i '154i type_drivers = flat,vlan,vxlan' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '155i tenant_network_types =' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '156i mechanism_drivers = linuxbridge' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '157i extension_drivers = port_security' /etc/neutron/plugins/ml2/ml2_conf.ini

sudo sed -i '225i enable_security_group = True' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '226i firewall_driver = iptables' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '227i enable_ipset = True' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i 's/^local\_ip\ \=/#local\_ip\ \=/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "284i local_ip = $MYIP" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
#sudo sed -i 's/local_ip\ \=\ 10.0.0.30/local_ip\ \=\ 10.0.0.30/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini


sudo sed -i '8i use_neutron = True'  /etc/nova/nova.conf
sudo sed -i '9i vif_plugging_is_fatal = True' /etc/nova/nova.conf
sudo sed -i '10i vif_plugging_timeout = 300' /etc/nova/nova.conf

echo "
[neutron]
auth_url = http://controller:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = servicepassword
service_metadata_proxy = True
metadata_proxy_shared_secret = metadata_secret" |sudo tee -a /etc/nova/nova.conf

sudo ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
sudo systemctl restart nova-compute neutron-linuxbridge-agent
sudo systemctl enable neutron-linuxbridge-agent

sudo sed -i '207i flat_networks = physnet1' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "190i physical_interface_mappings = physnet1:$ETH1" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '257i enable_vxlan = false' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

sudo systemctl restart neutron-linuxbridge-agent
#projectID=$(openstack project list | grep service | awk '{print $2}')
#openstack network create --project $projectID --share --provider-network-type flat --provider-physical-network physnet1 sharednet1
#openstack subnet create subnet1 --network sharednet1 --project $projectID --subnet-range $SUBNET1.0/24 --allocation-pool start=$SUBNET1.200,end=$SUBNET1.254 --gateway $SUBNET1.1 --dns-nameserver $SUBNET1.10
#openstack network list
