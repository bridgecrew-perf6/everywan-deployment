#!/bin/bash

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.secure.yml pull
docker-compose -f docker-compose.physical.secure.yml up --detach
