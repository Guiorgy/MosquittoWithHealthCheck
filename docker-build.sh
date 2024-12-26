#!/bin/bash

if [ -n "$1" ]; then
  TAG="$1"
else
  TAG='latest'
fi

echo "Building mosquitto-hc:$TAG image"
docker build --build-arg TAG="$TAG" -t "mosquitto-hc:$TAG" -f Dockerfile .

echo "Saving image as mosquitto-hc-$TAG.tar.gz"
docker save "mosquitto-hc:$TAG" | gzip > "./mosquitto-hc-$TAG.tar.gz"
