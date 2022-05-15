#!/bin/sh

cd /workdir
echo "Renewing Let's Encrypt Certificates... (`date`)"
docker-compose -f docker-compose.physical.secure.yml run --entrypoint certbot certbot renew
echo "Reloading Nginx configuration"
docker-compose -f docker-compose.physical.secure.yml exec -T everygui nginx -s reload
