#!/bin/bash

if [ -n "$1" ]; then
  TAG="$1"
else
  TAG='latest'
fi

echo "Building image for $TAG"

docker build --build-arg TAG="$TAG" -t "mosquitto-hc:$TAG" -f Dockerfile .
docker save "mosquitto-hc:$TAG" | gzip > "./mosquitto-hc-$TAG.tar.gz"
