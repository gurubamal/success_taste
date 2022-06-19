
git clone https://github.com/gurubamal/success_taste.git
cd success_taste/openstack_with_ceph
cp -ar wallaby /root/files
#RUN it on node7
cd wallaby/
sed -i 's/ens4/enp0s3/g' installer.sh
sed -i 's/ens3/enp0s8/g' installer.sh 
chmod +x ./*.sh
./installer.sh 

ceph osd pool create images
rbd pool init images
sudo mkdir /ceph-deploy ; cd /ceph-deploy
ceph auth get-or-create client.glance mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=images' > ceph.client.glance.keyring
#ceph auth get-or-create client.glance | ssh root@192.168.58.6 sudo tee /etc/ceph/ceph.client.glance.keyring
ceph auth get-or-create client.glance | sudo tee /etc/ceph/ceph.client.glance.keyring
#ssh root@192.168.58.6 \ "sudo chown glance:glance /etc/ceph/ceph.client.glance.keyring ; sudo chmod 0640 /etc/ceph/ceph.client.glance.keyring"
chown glance:glance /etc/ceph/ceph.client.glance.keyring ; sudo chmod 0640 /etc/ceph/ceph.client.glance.keyring
cp /etc/glance/glance-api.conf /etc/glance/glance-api.conf.bak

echo "[DEFAULT]
show_image_direct_url = True
[cors]
[cors.subdomain]
[image_format]
disk_formats = ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso,ploop.root-tar
[matchmaker_redis]
[oslo_concurrency]
[oslo_messaging_amqp]
[oslo_messaging_kafka]
[oslo_messaging_notifications]
[oslo_messaging_rabbit]
[oslo_messaging_zmq]
[oslo_middleware]
[oslo_policy]
[profiler]
[store_type_location_strategy]
[task]
[taskflow_executor]
[database]
backend = sqlalchemy
connection = mysql+pymysql://glance:avi123@localhost/glance
[glance_store]
#stores = file,http
#default_store = file
#filesystem_store_datadir = /var/lib/glance/images/
default_store = rbd
stores = file,http,rbd
rbd_store_pool = images
rbd_store_user = glance
rbd_store_ceph_conf = /etc/ceph/ceph.conf
rbd_store_chunk_size = 8
[image_format]
[keystone_authtoken]
www_authenticate_uri = http://localhost:5000
auth_url = http://localhost:5000
memcached_servers = localhost:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = glance
password = avi123 
[paste_deploy]
flavor = keystone" | sudo tee /etc/glance/glance-api.conf

chmod 640 /etc/glance/glance-api.conf
chown root:glance /etc/glance/glance-api.conf
su -s /bin/bash glance -c "glance-manage db_sync"
systemctl restart glance-api
systemctl enable glance-api
source /root/admin-openrc.sh
wget http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img
openstack image create "cirros-ceph" --file cirros-0.3.4-x86_64-disk.img --disk-format qcow2 --container-format bare --public
rbd -p images ls
