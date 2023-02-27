#!/bin/bash
docker run --name envoy -p 8001:80 -v /tmp/envoy.yaml:/etc/envoy/envoy.yaml -d envoyproxy/envoy:v1.22.8
