#!/bin/bash
docker run --name caddy -d -p 8000:80 -v /tmp/Caddyfile:/etc/caddy/Caddyfile caddy:2.3.0
