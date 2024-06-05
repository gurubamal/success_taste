#!/bin/bash

# Authored by: Ram Nath Bamal (Guru)

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y
if [ $? -ne 0 ]; then
  echo "Error: Failed to update and upgrade the system."
fi

# Install required packages
sudo apt install -y openjdk-11-jdk yarn npm rbenv elinks ruby-dev
if [ $? -ne 0 ]; then
  echo "Error: Failed to install required packages."
fi

# Add PostgreSQL repository and install PostgreSQL
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | sudo apt-key add -
if [ $? -ne 0 ]; then
  echo "Error: Failed to add PostgreSQL GPG key."
fi

sudo apt update
sudo apt install -y postgresql postgresql-contrib
if [ $? -ne 0 ]; then
  echo "Error: Failed to install PostgreSQL."
fi

sudo systemctl enable postgresql
sudo systemctl start postgresql
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable and start PostgreSQL."
fi

# Set PostgreSQL password
echo "postgres:postgres" | sudo chpasswd
if [ $? -ne 0 ]; then
  echo "Error: Failed to set PostgreSQL password."
fi

# Create PostgreSQL user and database for SonarQube
sudo su - postgres -c "createuser sonar"
sudo -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED password '22soGooD';"
sudo -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
if [ $? -ne 0 ]; then
  echo "Error: Failed to set up PostgreSQL for SonarQube."
fi

# Install zip
sudo apt install -y zip
if [ $? -ne 0 ]; then
  echo "Error: Failed to install zip."
fi

# Download and set up SonarQube
if [ ! -f sonarqube-9.0.1.46107.zip ]; then
  sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.0.1.46107.zip
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download SonarQube."
  fi
fi

if [ ! -d /opt/sonarqube ]; then
  sudo unzip sonarqube-9.0.1.46107.zip -d /opt/
  sudo mv /opt/sonarqube-9.0.1.46107 /opt/sonarqube
  if [ $? -ne 0 ]; then
    echo "Error: Failed to set up SonarQube."
  fi
else
  echo "SonarQube is already available."
fi

# Create sonar group and user
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube -R
if [ $? -ne 0 ]; then
  echo "Error: Failed to create SonarQube user and group."
fi

# Update SonarQube configuration
if ! grep -q "RUN_AS_USER=sonar" /opt/sonarqube/bin/linux-x86-64/sonar.sh; then
  sudo sed -i 's/#RUN_AS_USER=/RUN_AS_USER=sonar/g' /opt/sonarqube/bin/linux-x86-64/sonar.sh
  if [ $? -ne 0 ]; then
    echo "Error: Failed to update SonarQube configuration."
  fi
else
  echo "RUN_AS_USER=sonar is already set."
fi

# Create systemd service for SonarQube
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
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/sonar.service

sudo systemctl enable sonar
sudo systemctl start sonar
if [ $? -ne 0 ]; then
  echo "Error: Failed to enable and start SonarQube service."
fi

# Update sysctl configuration
echo "vm.max_map_count=262144
fs.file-max=65536
ulimit -n 65536
ulimit -u 4096" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
if [ $? -ne 0 ]; then
  echo "Error: Failed to update sysctl configuration."
fi

# Download and set up Sonar Scanner
FILE=/home/vagrant/sonar-scanner-cli-4.7.0.2747-linux.zip
if [ ! -f "$FILE" ]; then
  sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download Sonar Scanner."
  fi
fi

if [ ! -d /home/vagrant/sonar-scanner-*-linux ]; then
  sudo unzip sonar-scanner-cli-4.7.0.2747-linux.zip
  if [ $? -ne 0 ]; then
    echo "Error: Failed to unzip Sonar Scanner."
  fi
fi

if [ ! -d /opt/sonarscanner ]; then
  sudo mv sonar-scanner-*-linux /opt/sonarscanner
  if [ $? -ne 0 ]; then
    echo "Error: Failed to move Sonar Scanner."
  fi
fi

# Update Sonar Scanner configuration
echo "sonar.host.url=http://localhost:9000
sonar.sourceEncoding=UTF-8" | sudo tee -a /opt/sonarscanner/conf/sonar-scanner.properties
if [ $? -ne 0 ]; then
  echo "Error: Failed to update Sonar Scanner configuration."
fi

# Install Maven
sudo apt install -y maven
if [ $? -ne 0 ]; then
  echo "Error: Failed to install Maven."
fi

# Add Sonar Scanner to PATH
if ! grep -q sonarscanner /home/vagrant/.bashrc; then
  echo "export PATH=\$PATH:/opt/sonarscanner/bin" | sudo tee -a /home/vagrant/.bashrc
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add Sonar Scanner to PATH in /home/vagrant/.bashrc."
  fi
else
  echo "Sonar Scanner is already available in PATH for vagrant."
fi

if ! sudo grep -q sonarscanner /root/.bashrc; then
  echo "export PATH=\$PATH:/opt/sonarscanner/bin" | sudo tee -a /root/.bashrc
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add Sonar Scanner to PATH in /root/.bashrc."
  fi
else
  echo "Sonar Scanner is already available in PATH for root."
fi

# Download and set up Dependency Check
FILE=/home/vagrant/dependency-check-7.0.0-release.zip
if [ ! -f "$FILE" ]; then
  wget https://github.com/jeremylong/DependencyCheck/releases/download/v7.0.0/dependency-check-7.0.0-release.zip
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download Dependency Check."
  fi
fi

if [ ! -d /home/vagrant/dependency-check ]; then
  sudo unzip dependency-check-7.0.0-release.zip
  if [ $? -ne 0 ]; then
    echo "Error: Failed to unzip Dependency Check."
  fi
fi

# Install additional packages
sudo apt-get install -y openjdk-8-jdk golang python3-pip rubygems
if [ $? -ne 0 ]; then
  echo "Error: Failed to install additional packages."
fi

# Install bundler-audit gem
sudo gem install bundler-audit
if [ $? -ne 0 ]; then
  echo "Error: Failed to install bundler-audit gem."
fi

# Install pnpm
pip install pnpm
if [ $? -ne 0 ]; then
  echo "Error: Failed to install pnpm."
fi

# Install and configure .NET SDK and runtime
sudo snap install dotnet-sdk --classic --channel=6.0
sudo snap alias dotnet-sdk.dotnet dotnet
sudo snap install dotnet-runtime-60 --classic
sudo snap alias dotnet-runtime-60.dotnet dotnet-runtime
if [ $? -ne 0 ]; then
  echo "Error: Failed to install and configure .NET SDK and runtime."
fi

# Add DOTNET_ROOT to PATH
if ! grep -q DOTNET_ROOT /home/vagrant/.bashrc; then
  echo "export DOTNET_ROOT=/snap/dotnet-sdk/current" | sudo tee -a /home/vagrant/.bashrc
  if [ $? -ne 0 ]; then
    echo "Error: Failed to add DOTNET_ROOT to PATH in /home/vagrant/.bashrc."
  fi
else
  echo "DOTNET_ROOT is already available in PATH for vagrant."
fi

# Disable and stop AppArmor
sudo systemctl disable apparmor
sudo systemctl stop apparmor
if [ $? -ne 0 ]; then
  echo "Error: Failed to disable and stop AppArmor."
fi

# Update Dependency Check
sudo /home/vagrant/dependency-check/bin/dependency-check.sh --updateonly
if [ $? -ne 0 ]; then
  echo "Error: Failed to update Dependency Check."
fi
