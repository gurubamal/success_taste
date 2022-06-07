CONTROLNODEIP=$(grep controller  /etc/hosts|awk '{print $1}')
MYIP=192.168.58.7

#echo "$CONTROLNODEIP node5 controller" |sudo tee -a /etc/hosts
source  ~/keystonerc
sudo apt -y install software-properties-common
sudo add-apt-repository -y cloud-archive:wallaby
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
sudo apt -y install qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
sudo apt -y install nova-compute nova-compute-kvm qemu-system-data

sudo mv /etc/nova/nova.conf /etc/nova/nova.conf.org

echo "
# create new
[DEFAULT]
# define IP address
my_ip = 10.0.0.51
state_path = /var/lib/nova
enabled_apis = osapi_compute,metadata
log_dir = /var/log/nova
# RabbitMQ connection info
transport_url = rabbit://openstack:password@10.0.0.30

[api]
auth_strategy = keystone

# enable VNC
[vnc]
enabled = True
server_listen = 0.0.0.0
server_proxyclient_address = $MYIP
novncproxy_base_url = http://10.0.0.30:6080/vnc_auto.html

# Glance connection info
[glance]
api_servers = http://10.0.0.30:9292

[oslo_concurrency]
lock_path = $state_path/tmp

# Keystone auth info
[keystone_authtoken]
www_authenticate_uri = http://10.0.0.30:5000
auth_url = http://10.0.0.30:5000
memcached_servers = 10.0.0.30:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = servicepassword

[placement]
auth_url = http://10.0.0.30:5000
os_region_name = RegionOne
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = placement
password = servicepassword

[wsgi]
api_paste_config = /etc/nova/api-paste.ini" | sudo tee /etc/nova/nova.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/nova/nova.conf

sudo sed -i 's/^my_ip/\#my_ip/g' /etc/nova/nova.conf
sudo sed -i "5i my_ip = $MYIP" /etc/nova/nova.conf

 
sudo chmod 640 /etc/nova/nova.conf
sudo chgrp nova /etc/nova/nova.conf
sudo systemctl restart nova-compute

echo "
RUN FOLLWING COMMANDS ON CONTROL NODE FOR NEW HOSTS LIST REFRESH:

sudo su -s /bin/bash nova -c "nova-manage cell_v2 discover_hosts"
openstack compute service list"


