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
docker run --name envoy --rm -p 80:80 -v /tmp/envoy.yaml:/etc/envoy/envoy.yaml -d envoyproxy/envoy:v1.14.1

# Install Hey
wget -O hey https://storage.googleapis.com/hey-release/hey_linux_amd64
chmod +x ./hey