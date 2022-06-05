openstack user create --domain default --project service --password servicepassword nova
openstack role add --project service --user nova admin
openstack user create --domain default --project service --password servicepassword placement
openstack role add --project service --user placement admin
openstack service create --name nova --description "OpenStack Compute service" compute
openstack service create --name placement --description "OpenStack Compute Placement service" placement
export controller=controller
openstack endpoint create --region RegionOne compute public http://$controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$controller:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne placement public http://$controller:8778
openstack endpoint create --region RegionOne placement internal http://$controller:8778
openstack endpoint create --region RegionOne placement admin http://$controller:8778


sudo mysql -uroot -proot -e "create database nova";
sudo mysql -uroot -proot -e "grant all privileges on nova.* to nova@'localhost' identified by 'password'"; 
sudo mysql -uroot -proot -e "grant all privileges on nova.* to nova@'%' identified by 'password'"; 

sudo mysql -uroot -proot -e "create database nova_api"; 
sudo mysql -uroot -proot -e "grant all privileges on nova_api.* to nova@'localhost' identified by 'password'"; 
sudo mysql -uroot -proot -e "grant all privileges on nova_api.* to nova@'%' identified by 'password'"; 

sudo mysql -uroot -proot -e "create database placement"; 
sudo mysql -uroot -proot -e "grant all privileges on placement.* to placement@'localhost' identified by 'password'"; 
sudo mysql -uroot -proot -e "grant all privileges on placement.* to placement@'%' identified by 'password'"; 

sudo mysql -uroot -proot -e "create database nova_cell0"; 
sudo mysql -uroot -proot -e "grant all privileges on nova_cell0.* to nova@'localhost' identified by 'password'"; 
sudo mysql -uroot -proot -e "grant all privileges on nova_cell0.* to nova@'%' identified by 'password'"; 

sudo mysql -uroot -proot -e "flush privileges";

sudo apt -y install nova-api nova-conductor nova-scheduler nova-novncproxy placement-api python3-novaclient

sudo mv /etc/nova/nova.conf /etc/nova/nova.conf.org

echo "# create new
[DEFAULT]
# define IP address
my_ip = 10.0.0.30
state_path = /var/lib/nova
enabled_apis = osapi_compute,metadata
log_dir = /var/log/nova
# RabbitMQ connection info
transport_url = rabbit://openstack:password@10.0.0.30

[api]
auth_strategy = keystone

# Glance connection info
[glance]
api_servers = http://10.0.0.30:9292

[oslo_concurrency]
lock_path = $state_path/tmp

# MariaDB connection info
[api_database]
connection = mysql+pymysql://nova:password@10.0.0.30/nova_api

[database]
connection = mysql+pymysql://nova:password@10.0.0.30/nova

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
api_paste_config = /etc/nova/api-paste.ini" |sudo tee /etc/nova/nova.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/nova/nova.conf
chmod 640 /etc/nova/nova.conf
chgrp nova /etc/nova/nova.conf
mv /etc/placement/placement.conf /etc/placement/placement.conf.org

echo "# create new
[DEFAULT]
debug = false

[api]
auth_strategy = keystone

[keystone_authtoken]
www_authenticate_uri = http://10.0.0.30:5000
auth_url = http://10.0.0.30:5000
memcached_servers = 10.0.0.30:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = placement
password = servicepassword

[placement_database]
connection = mysql+pymysql://placement:password@10.0.0.30/placement" |sudo tee /etc/placement/placement.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/placement/placement.conf

sudo chmod 640 /etc/placement/placement.conf
sudo chgrp placement /etc/placement/placement.conf

sudo su -s /bin/bash placement -c "placement-manage db sync"
sudo su -s /bin/bash nova -c "nova-manage api_db sync"
sudo su -s /bin/bash nova -c "nova-manage cell_v2 map_cell0"
sudo su -s /bin/bash nova -c "nova-manage db sync"
sudo su -s /bin/bash nova -c "nova-manage cell_v2 create_cell --name cell1"
sudo systemctl restart apache2

for service in api conductor scheduler novncproxy; do
sudo systemctl restart nova-$service
done

openstack compute service list
