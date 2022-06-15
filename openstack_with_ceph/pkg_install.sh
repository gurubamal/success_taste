apt-get install -y net-tools software-properties-common
add-apt-repository -y cloud-archive:wallaby
#apt-mark hold ceph ceph-mgr-dashboard
apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
apt-get install -y python3-openstackclient python3-pip git
apt-get install -y ssh-client
#apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
#add-apt-repository 'deb [arch=amd64,arm64,ppc64el] https://mirror.vpsfree.cz/mariadb/repo/10.4/ubuntu bionic main'
apt-get update && apt-get -y install mariadb-server
apt-get -y install python3-pymysql && service mysql restart
apt-get -y install rabbitmq-server memcached python3-pymysql
apt-get -y install apache2 
apt-get -y install libapache2-mod-wsgi
apt-get -y install memcached
apt-get -y install python3-memcache
apt-get -y install keystone
apt-get -y install python3-openstackclient  libapache2-mod-wsgi-py3 python3-oauth2client
apt-get -y install glance
apt-get -y install placement-api
apt -y install cinder-api cinder-scheduler python3-cinderclient
apt -y install nova-api nova-conductor nova-scheduler nova-novncproxy placement-api python3-novaclient
apt -y install nova-compute nova-compute-kvm qemu-system-data qemu-kvm libvirt-daemon-system libvirt-daemon virtinst bridge-utils libosinfo-bin libguestfs-tools virt-top
#apt-get -y install nova-api nova-conductor nova-novncproxy nova-scheduler
apt-get install -y nova-compute
#apt-get -y install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-dhcp-agent neutron-metadata-agent neutron-l3-agent
apt-get -y install install neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent python3-neutronclient 
apt-get install -y openstack-dashboard
apt-get install heat-api heat-api-cfn heat-engine python3-zunclient python3-vitrageclient -y
