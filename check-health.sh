#!/bin/ash

if ! mosquitto_sub -p "$HEALTHCHECK_PORT" -t '$SYS/broker/uptime' -C 1 -i healthcheck -W 2; then
  exit 1
else
  exit 0
fi
