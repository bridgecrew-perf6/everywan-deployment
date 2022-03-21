#!/bin/bash

# Create a folder to store MongoDB data
sudo mkdir -p /var/everywan/mongodb

# Create a folder to store Keystone data
sudo mkdir -p /var/everywan/keystone-database

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.yml build keystone
docker-compose -f docker-compose.physical.yml pull database mongodb everyboss everyedgeos everygui
docker-compose -f docker-compose.physical.yml up --detach
