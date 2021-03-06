#!/bin/bash
docker run --name traefik -d -p 8004:80 -v /tmp/dynamic_conf.toml:/etc/traefik/dynamic_conf.toml -v /tmp/traefik.toml:/etc/traefik/traefik.toml traefik:v2.4.5
