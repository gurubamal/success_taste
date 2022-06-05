sudo mysql -uroot -proot -e "create database keystone";
sudo mysql -uroot -proot -e "grant all privileges on keystone.* to keystone@'localhost' identified by 'password'";
sudo mysql -uroot -proot -e "grant all privileges on keystone.* to keystone@'%' identified by 'password'";
sudo mysql -uroot -proot -e "flush privileges";

sudo  apt -y install keystone python3-openstackclient apache2 libapache2-mod-wsgi-py3 python3-oauth2client
sudo sed -i 's/\#memcache\_servers\ \=\ localhost\:11211/memcache\_servers\ \=\ controller\:11211/g' /etc/keystone/keystone.conf
sudo sed -i 's/connection\ \=\ sqlite\:\/\/\/\/var\/lib\/keystone\/keystone.db/connection\ \=\ mysql\+pymysql\:\/\/keystone\:password\@controller\/keystone/g' /etc/keystone/keystone.conf
sudo sed -i  's/\#provider\ \=\ fernet/provider\ \=\ fernet/g' /etc/keystone/keystone.conf
sudo su -s /bin/bash keystone -c "keystone-manage db_sync"
sudo keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
sudo keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

export controller=controller
sudo keystone-manage bootstrap --bootstrap-password adminpassword \
--bootstrap-admin-url http://$controller:5000/v3/ \
--bootstrap-internal-url http://$controller:5000/v3/ \
--bootstrap-public-url http://$controller:5000/v3/ \
--bootstrap-region-id RegionOne

sudo sed -i 's/\#ServerRoot \"\/etc\/apache2\"/ServerName\ controller/g' /etc/apache2/apache2.conf
sudo systemctl restart apache2

echo "export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=adminpassword
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
export PS1='\u@\h \W(keystone)\$ '" |sudo tee ~/keystonerc
sudo cp  ~/keystonerc /root/keystonerc
sudo chmod 600 ~/keystonerc
source  ~/keystonerc
echo "source ~/keystonerc" |sudo tee -a  ~/.bash_profile
openstack project create --domain default --description "Service Project" service
openstack project list
