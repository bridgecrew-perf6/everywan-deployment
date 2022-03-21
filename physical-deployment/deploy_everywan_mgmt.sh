#!/bin/bash

cd ../everywan-dockerized
docker-compose -f docker-compose.physical.yml pull
docker-compose -f docker-compose.physical.yml up --detach
