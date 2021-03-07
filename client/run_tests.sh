#!/bin/bash

echo "--------------------" 
echo "        caddy" 
echo "--------------------" 
/home/ubuntu/hey -n 100000 -c 250 -m GET http://192.168.0.11:8000 

echo "--------------------" 
echo "        envoy" 
echo "--------------------" 
/home/ubuntu/hey -n 100000 -c 250 -m GET http://192.168.0.11:8001 

echo "--------------------" 
echo "        haproxy" 
echo "--------------------" 
/home/ubuntu/hey -n 100000 -c 250 -m GET http://192.168.0.11:8002 

echo "--------------------" 
echo "        nginx" 
echo "--------------------" 
/home/ubuntu/hey -n 100000 -c 250 -m GET http://192.168.0.11:8003 

echo "--------------------" 
echo "        traefik" 
echo "--------------------" 
/home/ubuntu/hey -n 100000 -c 250 -m GET http://192.168.0.11:8004 
