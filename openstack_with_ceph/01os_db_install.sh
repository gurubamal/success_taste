echo "
127.0.0.1 localhost vagrant
192.168.58.7 node7 node02
192.168.58.6 node6 node01
192.168.58.8 node8 node03 controller" |sudo tee /etc/hosts
sudo apt update
sudo apt -y install mariadb-server
sudo systemctl restart mariadb
echo "UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;" |sudo tee mysql_secure_installation.sql
sudo mysql -sfu root < "mysql_secure_installation.sql"
