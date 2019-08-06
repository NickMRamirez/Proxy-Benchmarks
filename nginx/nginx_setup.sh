#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt update && apt install -y nginx \
  && cp -f /tmp/nginx.conf /etc/nginx/nginx.conf \
  && systemctl restart nginx

# Install Hey
wget -O hey https://storage.googleapis.com/hey-release/hey_linux_amd64
chmod +x ./hey