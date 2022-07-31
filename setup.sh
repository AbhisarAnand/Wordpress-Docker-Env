#!/bin/bash

# Prompt user for password
echo "What is your password: "
read password

# Make Directories
echo "...Making Directories..."
[ -d wordpress ] || mkdir wordpress
[ -d mysql ] || mkdir mysql
[ -d schema ] || mkdir schema
echo "...Directories Made..."

# Download Database Files
echo "...Downloading Database Files..."
curl -L https://dropbox.com/s/xs4281xr6tbdvuw/pharmaceuticalintelligence.com-20220728-193009-gewymu.wpress?dl=0 -o backup.wpress
npx wpress-extract backup.wpress
mv backup/database.sql /schema/.
echo "...Database Files Downloaded..."

# Download WP-Content Files
echo "...Reconfiguring WP-Content Files..."
cd wordpress
[ -d wp-content ] || mkdir wp-content
cd wp-content
[ -d ai1wm-backups ] || mkdir ai1wm-backups
[ -d cache ] || mkdir cache
[ -d upgrade ] || mkdir upgrade
cd ..
cd ..
mv backup/mu-plugins wordpress/wp-content/
mv backup/plugins wordpress/wp-content/
mv backup/themes wordpress/wp-content/
mv backup/uploads wordpress/wp-content/
mv backup/index.php wordpress/wp-content/
echo "...WP-Content Files Reconfigured..."

# Run Docker Container
echo "...Running Docker Container..."
docker compose up -d
sleep 15
echo "...Docker Container Running..."

# Create Database
echo "...Setting Up Database..."
mysql -u root -p$password -h 0.0.0.0 -P 9004 <<-EOF
DROP DATABASE IF EXISTS LPBI;
CREATE DATABASE LPBI;
USE LPBI;
SET SQL_MODE='ALLOW_INVALID_DATES';
SOURCE schema/database.sql;
EOF
echo "...Database Set Up..."

# Stop Docker Container
echo "...Stopping Docker Container..."
docker compose down
echo "...Docker Container Stopping..."
