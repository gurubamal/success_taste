sudo apt update
sudo apt -y install software-properties-common
sudo add-apt-repository cloud-archive:wallaby -y
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"
#sudo apt -y upgrade
sudo apt -y install rabbitmq-server memcached python3-pymysql
sudo rabbitmqctl add_user openstack password
sudo rabbitmqctl set_permissions openstack ".*" ".*" ".*"
sudo sed -i 's/bind-address\            \=\ 127.0.0.1/bind-address\            \=\ 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/\#max_connections\        \=\ 100/max_connections\        \=\ 500/g'  /etc/mysql/mariadb.conf.d/50-server.cnf
sudo sed -i 's/\-l\ 127.0.0.1/\-l\ 0.0.0.0/g' /etc/memcached.conf
sudo systemctl restart mariadb rabbitmq-server memcached
