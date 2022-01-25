#!/bin/bash

cd ../everywan-dockerized
docker-compose up --build mongodb everyboss everygui keystone database
