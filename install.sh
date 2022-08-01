#!/bin/bash

# Prompt user for password
echo "What is the password you would like to use for everything: "
read password

# Update the system
sudo apt update
sudo apt list --upgradable

# Apache2 Installation
sudo apt -qy install apache2 apache2-doc libexpat1 ssl-cert

# MySQL Installation
echo "...Installing MySQL..."
sudo apt install aptitude -y
sudo apt install mysql-server -y
sudo systemctl start mysql.service
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY $password;"
mysql -u root <<-EOF
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DELETE FROM mysql.user WHERE User='';
FLUSH PRIVILEGES;
EOF
mysql -u root -p$password -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;"
mysql -u root -p$password -e "CREATE USER 'abhisar'@'localhost' IDENTIFIED BY $password; GRANT ALL PRIVILEGES ON *.* TO 'abhisar'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;"
echo "...MySQL Installed..."

# Docker Installation
echo "...Installing Docker..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker abhisar
echo "...Docker Installed..."

# Docker Compose Installation
echo "...Installing Docker Compose..."
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.3.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
echo "...Docker Compose Installed..."

# phpMyAdmin Installation
echo "...Installing phpMyAdmin..."
mysql -u root -p$password -e "UNINSTALL COMPONENT 'file://component_validate_password';";
sudo apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y
mysql -u root -p$password -e "INSTALL COMPONENT 'file://component_validate_password';";
sudo phpenmod mbstring
sudo systemctl restart apache2
echo "...phpMyAdmin Installed..."

# Install Node and NPM
echo "...Installing Node and NPM..."
sudo apt install nodejs -y
sudo apt install npm -y
echo "...Node and NPM Installed..."

# Clean up
echo "...Cleaning Up..."
sudo apt autoremove
echo "...Cleaned Up..."
