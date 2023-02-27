#!/bin/bash
docker run --name haproxy -d -p 8002:80 -v /tmp/haproxy.cfg:/etc/haproxy/haproxy.cfg haproxytech/haproxy-ubuntu:2.7.3
