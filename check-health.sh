#!/bin/ash

if [ -z "$HEALTHCHECK_USERNAME" ] && [ -z "$HEALTHCHECK_PASSWORD" ]; then
  if ! mosquitto_sub -p "$HEALTHCHECK_PORT" -t '$SYS/broker/uptime' -C 1 -i healthcheck -W 2; then
    exit 1
  fi
else
  if ! mosquitto_sub -p "$HEALTHCHECK_PORT" -u "$HEALTHCHECK_USERNAME" -P "$HEALTHCHECK_PASSWORD" -t '$SYS/broker/uptime' -C 1 -i healthcheck -W 2; then
    exit 1
  fi
fi

exit 0
