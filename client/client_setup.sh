#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Install Hey
wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x ./hey

sysctl -w net.ipv4.ip_local_port_range="1024 65535"
sysctl -w net.ipv4.tcp_tw_reuse=1
sysctl -w net.ipv4.tcp_timestamps=1
ulimit -n 250000
