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
