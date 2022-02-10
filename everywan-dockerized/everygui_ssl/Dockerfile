FROM ghcr.io/cscarpitta/everygui:latest

RUN apt-get update
RUN apt-get install -y openssl

COPY default.conf /etc/nginx/conf.d/
COPY options-ssl-nginx.conf /etc/nginx/
COPY hsts.conf /etc/nginx/
COPY nginx.sh /opt/

RUN chmod +x /opt/nginx.sh

EXPOSE 80

CMD ["/opt/nginx.sh"]
