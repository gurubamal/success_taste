openstack user create --domain default --project service --password servicepassword glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image service" image
export controller=controller
openstack endpoint create --region RegionOne image public http://$controller:9292
openstack endpoint create --region RegionOne image internal http://$controller:9292
openstack endpoint create --region RegionOne image admin http://$controller:9292
sudo mysql -uroot -proot -e "create database glance";
sudo mysql -uroot -proot -e "grant all privileges on glance.* to glance@'localhost' identified by 'password'";
sudo mysql -uroot -proot -e "grant all privileges on glance.* to glance@'%' identified by 'password'";
sudo mysql -uroot -proot -e "flush privileges";

sudo apt -y install glance
sudo mv /etc/glance/glance-api.conf /etc/glance/glance-api.conf.org
echo "# create new
[DEFAULT]
bind_host = 0.0.0.0

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/

[database]
# MariaDB connection info
connection = mysql+pymysql://glance:password@10.0.0.30/glance

# keystone auth info
[keystone_authtoken]
www_authenticate_uri = http://10.0.0.30:5000
auth_url = http://10.0.0.30:5000
memcached_servers = 10.0.0.30:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = servicepassword

[paste_deploy]
flavor = keystone" |sudo tee  /etc/glance/glance-api.conf
sudo sed -i  's/10.0.0.30/controller/g' /etc/glance/glance-api.conf
sudo chmod 640 /etc/glance/glance-api.conf
sudo chown root:glance /etc/glance/glance-api.conf
su -s /bin/bash glance -c "glance-manage db_sync"
systemctl restart glance-api
systemctl enable glance-api
