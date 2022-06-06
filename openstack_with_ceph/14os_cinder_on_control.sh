MYIP=$(hostname -I|awk '{print $NF}')

openstack user create --domain default --project service --password servicepassword cinder
openstack role add --project service --user cinder admin
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
export controller=controller
openstack endpoint create --region RegionOne volumev3 public http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$controller:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$controller:8776/v3/%\(tenant_id\)s

sudo mysql -uroot -proot -e "create database cinder";
sudo mysql -uroot -proot -e "grant all privileges on cinder.* to cinder@'localhost' identified by 'password'";
sudo mysql -uroot -proot -e "grant all privileges on cinder.* to cinder@'%' identified by 'password'";
sudo mysql -uroot -proot -e "flush privileges";

sudo apt -y install cinder-api cinder-scheduler python3-cinderclient cinder-volume python3-mysqldb python3-rtslib-fb
sudo mv /etc/cinder/cinder.conf /etc/cinder/cinder.conf.org

echo "
# create new
[DEFAULT]
# define own IP address
my_ip = $MYIP
rootwrap_config = /etc/cinder/rootwrap.conf
api_paste_confg = /etc/cinder/api-paste.ini
state_path = /var/lib/cinder
auth_strategy = keystone
# RabbitMQ connection info
transport_url = rabbit://openstack:password@10.0.0.30
enable_v3_api = True
glance_api_servers = http://controller:9292
enabled_backends =

# MariaDB connection info
[database]
connection = mysql+pymysql://cinder:password@10.0.0.30/cinder

# Keystone auth info
[keystone_authtoken]
www_authenticate_uri = http://10.0.0.30:5000
auth_url = http://10.0.0.30:5000
memcached_servers = 10.0.0.30:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = servicepassword

[oslo_concurrency]
lock_path = $state_path/tmp" |sudo tee /etc/cinder/cinder.conf

sudo sed -i 's/10.0.0.30/controller/g' /etc/cinder/cinder.conf
sudo chmod 640 /etc/cinder/cinder.conf
sudo chgrp cinder /etc/cinder/cinder.conf
sudo su -s /bin/bash cinder -c "cinder-manage db sync"
sudo systemctl restart cinder-scheduler
sudo systemctl enable cinder-scheduler
echo "export OS_VOLUME_API_VERSION=3" |sudo tee -a  ~/keystonerc
source ~/keystonerc
openstack volume service list



