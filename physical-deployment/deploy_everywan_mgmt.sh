#!/bin/bash

# Create a folder to store MongoDB data
sudo mkdir -p /var/everywan/mongodb

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.yml build keystone
docker-compose -f docker-compose.physical.yml pull database mongodb everyboss everyedgeos everygui
docker-compose -f docker-compose.physical.yml up --detach
