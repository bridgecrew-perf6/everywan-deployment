#!/bin/bash

# Create a folder to store MongoDB data
sudo mkdir -p /var/everywan/mongodb

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.secure.yml build keystone everygui certbot cron
docker-compose -f docker-compose.physical.secure.yml pull database mongodb everyboss everyedgeos
docker-compose -f docker-compose.physical.secure.yml up --detach
