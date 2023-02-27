#!/bin/bash
docker run --name nginx -d -p 8003:80 -v /tmp/nginx.conf:/etc/nginx/nginx.conf nginx:1.22.1
