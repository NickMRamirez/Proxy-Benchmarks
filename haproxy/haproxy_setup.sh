#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Install Docker
if [ ! $(which docker) ]; then
    echo "----Installing docker----"
    apt update
    apt install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt update
    apt install -y docker-ce
fi

# Run the Docker container
docker run -d -p 80:80 -v /tmp/haproxy.cfg:/etc/haproxy/haproxy.cfg haproxytech/haproxy-ubuntu:2.3.5

# Install Hey
wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x ./hey
