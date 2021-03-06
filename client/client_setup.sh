#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Install Hey
wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
chmod +x ./hey