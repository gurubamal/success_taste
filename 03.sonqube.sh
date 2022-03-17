sudo apt update
sudo apt upgrade -y
sudo apt install -y openjdk-11-jdk yarn npm rbenv elinks ruby-dev
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
echo "postgres:postgres" | sudo chpasswd
sudo su - postgres -c "createuser sonar"
sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED password '22soGooD';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
sudo apt install -y zip
if [ ! -f sonarqube-9.0.1.46107.zip ]
	then
	sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
fi
#sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
if [ ! -d /opt/sonarqube ]
        then
        sudo sudo unzip sonarqube-9.0.1.46107.zip -d /opt/
	sudo mv /opt/sonarqube-9.0.1.46107 /opt/sonarqube
	else
	echo "sonarqube is available"
fi
#sudo unzip sonarqube-9.0.1.46107.zip -d /opt/
#sudo mv /opt/sonarqube-9.0.1.46107 /opt/sonarqube
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
#echo "sonar.jdbc.username=sonar
#sonar.jdbc.password=22soGooD
#sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube" |sudo tee -a /opt/sonarqube/conf/sonar.properties
if ! grep "RUN_AS_USER=sonar" /opt/sonarqube/bin/linux-x86-64/sonar.sh
	then 
	sudo sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh
	else
	echo "RUN_AS_USER=sonar is set"
fi
echo "[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=on-failure

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target" |sudo tee /etc/systemd/system/sonar.service

sudo systemctl enable sonar
sudo systemctl start sonar
#sudo systemctl status sonar

echo "vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096" |sudo tee -a /etc/sysctl.conf

#echo "sonar.web.javaAdditionalOpts=-server
#sonar.web.host=127.0.0.1" |sudo tee -a /opt/sonarqube/conf/sonar.properties
FILE=/home/vagrant/sonar-scanner-cli-4.7.0.2747-linux.zip
if [ -f "$FILE" ]
        then
                echo "$FILE exists."
        else
	sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
fi
FILE=/home/vagrant/sonar-scanner-*-linux

if [ -d "$FILE" ]
        then
                echo "$FILE exists."
        else
	sudo unzip sonar-scanner-cli-4.7.0.2747-linux.zip
fi
#sudo rm sonar-scanner-cli-4.7.0.2747-linux.zip
FILE=/opt/sonarscanner
if [ -d "$FILE" ]
        then
                echo "$FILE exists."
        else
	sudo mv sonar-scanner-*-linux /opt/sonarscanner
fi
echo "sonar.host.url=http://localhost:9000
sonar.sourceEncoding=UTF-8" |sudo tee -a  /opt/sonarscanner/conf/sonar-scanner.properties
sudo apt install -y maven
if ! grep sonarscanner /home/vagrant/.bashrc
    then
    echo "export PATH=$PATH:/opt/sonarscanner/bin" |sudo tee -a /home/vagrant/.bashrc
    else
        echo "sonarscanner is available"
fi
if ! sudo grep sonarscanner /root/.bashrc
    then
        echo "export PATH=$PATH:/opt/sonarscanner/bin" |sudo tee -a /root/.bashrc
    else
        echo "sonarscanner is available"
fi
FILE=/home/vagrant/dependency-check-7.0.0-release.zip
if [ -f "$FILE" ]
	then
		echo "$FILE exists."
	else
		wget https://github.com/jeremylong/DependencyCheck/releases/download/v7.0.0/dependency-check-7.0.0-release.zip
#		wget https://github.com/jeremylong/DependencyCheck/releases/download/v6.5.3/dependency-check-6.5.3-release.zip
fi
FILE2=/home/vagrant/dependency-check
if [ -d "$FILE2" ]; then
    	echo "$FILE2 is present"
	else 
	sudo unzip dependency-check-7.0.0-release.zip
fi

#FILE3=/opt/dependency-check
#if [ -d "$FILE3" ]; then
#        echo "$FILE3 is present"
#        else
#        sudo mv dependency-check /opt/dependency-check
#fi
#if ! grep dependency-check /home/vagrant/.bashrc
#    then
#    echo "export PATH=$PATH:/opt/dependency-check/bin/" |sudo tee -a /home/vagrant/.bashrc
#    else
#        echo "dependency-check is available"
#fi
sudo apt-get -y install openjdk-8-jdk golang python3-pip rubygems
#sudo update-java-alternatives --set /usr/lib/jvm/java-1.8.0-openjdk-amd64
#if ! grep JAVA_HOME /home/vagrant/.bashrc
#    then
#    echo "export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"" |sudo tee -a /home/vagrant/.bashrc
#    else
#        echo "JAVA_HOME was exported already"
#fi
#export JAVA_HOME="$(jrunscript -e 'java.lang.System.out.println(java.lang.System.getProperty("java.home"));')"
sudo gem install bundler-audit
pip install pnpm
sudo snap install dotnet-sdk --classic --channel=6.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install dotnet-runtime-60 --classic
sudo snap alias dotnet-runtime-60.dotnet dotnet-runtime
if ! grep DOTNET_ROOT /home/vagrant/.bashrc
   then
    echo "export DOTNET_ROOT=/snap/dotnet-sdk/current" |sudo tee -a /home/vagrant/.bashrc
    else
        echo "DOTNET_ROOT was exported already"
fi
sudo systemctl disable apparmor
sudo systemctl stop apparmor
#
#git clone --depth 1 https://github.com/jeremylong/DependencyCheck.git
#cd DependencyCheck
#mvn -s settings.xml install
#wget https://github.com/jeremylong/DependencyCheck/releases/download/v7.0.0/dependency-check-7.0.0-release.zip
sudo /home/vagrant/dependency-check/bin/dependency-check.sh --updateonly
#sudo mv dependency-check /opt/dependency-check
#sonar.exclusions=**/*.java option can be used for exclusions 
#You can run any code scan against latest vulnerabilities using following command:
#sudo /home/vagrant/dependency-check/bin/dependency-check.sh --noupdate --prettyPrint --format HTML -scan ./<your project code>
#sudo reboot
