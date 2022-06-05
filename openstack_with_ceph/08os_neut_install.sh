ETH1=eth1
controller_ip=192.168.58.5
controller=controller
SUBNET1=192.168.58

sudo apt -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python3-neutronclient
sudo mv /etc/neutron/neutron.conf /etc/neutron/neutron.conf.org

echo "# create new
[DEFAULT]
core_plugin = ml2
service_plugins = router
auth_strategy = keystone
state_path = /var/lib/neutron
dhcp_agent_notification = True
allow_overlapping_ips = True
notify_nova_on_port_status_changes = True
notify_nova_on_port_data_changes = True
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

# MariaDB connection info
[database]
connection = mysql+pymysql://neutron:password@10.0.0.30/neutron_ml2

# Nova connection info
[nova]
auth_url = http://10.0.0.30:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = servicepassword

[oslo_concurrency]
lock_path = $state_path/tmp" |sudo tee /etc/neutron/neutron.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/neutron/neutron.conf
sudo chmod 640 /etc/neutron/neutron.conf
sudo chgrp neutron /etc/neutron/neutron.conf

sudo sed -i '21i interface_driver = linuxbridge' /etc/neutron/l3_agent.ini

sudo sed -i '21i interface_driver = linuxbridge' /etc/neutron/dhcp_agent.ini
sudo sed -i 's/\#dhcp_driver\ \=\ neutron.agent.linux.dhcp.Dnsmasq/dhcp_driver\ \=\ neutron.agent.linux.dhcp.Dnsmasq/g' /etc/neutron/dhcp_agent.ini
sudo sed -i '52i enable_isolated_metadata = true' /etc/neutron/dhcp_agent.ini

sudo sed -i '22i nova_metadata_host = controller' /etc/neutron/metadata_agent.ini
sudo sed -i '34i metadata_proxy_shared_secret = metadata_secret' /etc/neutron/metadata_agent.ini
sudo sed -i '311i memcache_servers = controller:11211' /etc/neutron/metadata_agent.ini


#sudo sed -i '154i [ml2]' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '154i type_drivers = flat,vlan,vxlan' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '155i tenant_network_types =' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '156i mechanism_drivers = linuxbridge' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i '157i extension_drivers = port_security' /etc/neutron/plugins/ml2/ml2_conf.ini



#sudo sed -i '225i [securitygroup]'  /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '225i enable_security_group = True' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '226i firewall_driver = iptables' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '227i enable_ipset = True' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i 's/^local\_ip\ \=/#local\_ip\ \=/g' /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i "284i local_ip = $controller_ip" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
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

openstack user create --domain default --project service --password servicepassword neutron
openstack role add --project service --user neutron admin
openstack service create --name neutron --description "OpenStack Networking service" network
export controller=controller
openstack endpoint create --region RegionOne network public http://$controller:9696
openstack endpoint create --region RegionOne network internal http://$controller:9696
openstack endpoint create --region RegionOne network admin http://$controller:9696

sudo mysql -uroot -proot -e "create database neutron_ml2";
sudo mysql -uroot -proot -e "grant all privileges on neutron_ml2.* to neutron@'localhost' identified by 'password'";
sudo mysql -uroot -proot -e "grant all privileges on neutron_ml2.* to neutron@'%' identified by 'password'";
sudo mysql -uroot -proot -e "flush privileges";


sudo su -s /bin/bash neutron -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head"

for service in server l3-agent dhcp-agent metadata-agent linuxbridge-agent; do
sudo systemctl restart neutron-$service
sudo systemctl enable neutron-$service
done

sudo systemctl restart nova-api nova-compute

#ETH1=eth1
if ! grep IPv6AcceptRA /etc/systemd/network/$ETH1.network
	then echo "[Match]
Name=$ETH1

[Network]
LinkLocalAddressing=no
IPv6AcceptRA=no" |sudo tee -a /etc/systemd/network/$ETH1.network
	else echo "Interface $ETH1 is all Set already..."
fi

sudo systemctl restart systemd-networkd

sudo sed -i '207i flat_networks = physnet1' /etc/neutron/plugins/ml2/ml2_conf.ini
sudo sed -i "190i physical_interface_mappings = physnet1:$ETH1" /etc/neutron/plugins/ml2/linuxbridge_agent.ini
sudo sed -i '257i enable_vxlan = false' /etc/neutron/plugins/ml2/linuxbridge_agent.ini

sudo systemctl restart neutron-linuxbridge-agent

projectID=$(openstack project list | grep service | awk '{print $2}')

openstack network create --project $projectID --share --provider-network-type flat --provider-physical-network physnet1 sharednet1

openstack subnet create subnet1 --network sharednet1 --project $projectID --subnet-range $SUBNET1.0/24 --allocation-pool start=$SUBNET1.200,end=$SUBNET1.254 --gateway $SUBNET1.1 --dns-nameserver $SUBNET1.10

openstack network list


