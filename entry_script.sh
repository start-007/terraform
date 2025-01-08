#!/bin/bash

mkdir abc

sudo apt update -y 
sudo apt install -y docker.io
sudo chmod 666 /var/run/docker.sock
docker run -p 8080:80 nginx