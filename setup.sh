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
# TODO
npx wpress-extract *.wpress
echo "...Database Files Downloaded..."

# Download WP-Content Files
echo "...Downloading WP-Content Files..."
# TODO
echo "...WP-Content Files Downloaded..."

# Run Docker Container
echo "...Running Docker Container..."
docker-compose up -d
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

