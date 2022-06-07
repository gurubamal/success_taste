CONTROLNODE=192.168.58.5

sudo apt -y install openstack-dashboard
sudo sed -i "s/LOCATION': '127.0.0.1:11211/LOCATION': '$CONTROLNODE:11211/g"  /etc/openstack-dashboard/local_settings.py
sudo sed -i '113i SESSION_ENGINE = "django.contrib.sessions.backends.cache"' /etc/openstack-dashboard/local_settings.py

source  ~/keystonerc
# line 126 : set Openstack Host
# line 127 : comment out and add a line to specify URL of Keystone Host
sudo sed -i "s/127.0.0.1/$CONTROLNODE/g" /etc/openstack-dashboard/local_settings.py

#OPENSTACK_KEYSTONE_URL = "http://%s/identity/v3" % OPENSTACK_HOST
sudo sed -i "s/^OPENSTACK_KEYSTONE_URL/\#OPENSTACK_KEYSTONE_URL/g" /etc/openstack-dashboard/local_settings.py
sudo sed -i "113i OPENSTACK_KEYSTONE_URL = 'http://$CONTROLNODE:5000/v3'"  /etc/openstack-dashboard/local_settings.py

#sudo sed "s/OPENSTACK_KEYSTONE_URL = "http://%s/identity/v3" % OPENSTACK_HOST/OPENSTACK_KEY

#OPENSTACK_HOST = "127.0.0.1"
#OPENSTACK_KEYSTONE_URL = "http://%s/identity/v3" % OPENSTACK_HOST
# line 131 : set your timezone
# SET TIME_ZONE = "Asia/Tokyo"
sudo sed -i  "s/UTC/Asia\/Kolkata/g" /etc/openstack-dashboard/local_settings.py
#UTC to Asia/Kolkata
# add to the end
echo "
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'Default'" |sudo tee -a /etc/openstack-dashboard/local_settings.py


sudo systemctl restart apache2

echo "# created new
# default is [rule:system_admin_api], so only admin users can access to instances details or console
{
  "os_compute_api:os-extended-server-attributes": "rule:admin_or_owner",
}" |sudo tee /etc/nova/policy.json

sudo chgrp nova /etc/nova/policy.json
sudo chmod 640 /etc/nova/policy.json
sudo systemctl restart nova-api

