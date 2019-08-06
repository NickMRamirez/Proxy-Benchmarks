#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:vbernat/haproxy-2.0 \
  && apt update && apt install -y haproxy \
  && cp -f /home/ubuntu/haproxy.cfg /etc/haproxy/haproxy.cfg \
  && systemctl restart haproxy

# Install Hey
wget -O hey https://storage.googleapis.com/hey-release/hey_linux_amd64
chmod +x ./hey