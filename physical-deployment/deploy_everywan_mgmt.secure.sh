#!/bin/bash

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.secure.yml build --no-cache everygui
docker-compose -f docker-compose.physical.secure.yml build keystone certbot cron
docker-compose -f docker-compose.physical.secure.yml pull database mongodb everyboss everyedgeos
docker-compose -f docker-compose.physical.secure.yml up --detach
