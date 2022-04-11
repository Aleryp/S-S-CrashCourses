FROM ubuntu:20.04
MAINTAINER AleRyp

RUN apt-get update \
&& apt-get install -y nginx

RUN service nginx start

RUN echo "admin:admin" > /etc/nginx/.htpasswd

COPY nginx.conf /etc/nginx/

RUN nginx -T
RUN service nginx restart

EXPOSE 80 81
