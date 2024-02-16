#!/bin/ash
set -e

config_path='/mosquitto/config/mosquitto-with-healthcheck.conf'

# copy the base configuration
config=$(cat /mosquitto/config/mosquitto.conf)

# add a comment to the top of the configuration
config="# auto-generated
# modify /mosquitto/config/mosquitto.conf instead

$config"

# add a healthcheck listener to the bottom of the configuration
config="$config

# listener used for health checks
listener $HEALTHCHECK_PORT 127.0.0.1
socket_domain ipv4
sys_interval 60
allow_anonymous true"

# save the modified configuration
echo "$config" > "$config_path"

# run the base mosquitto entrypoint script and filter out healthcheck messages from its logs
/mosquitto-docker-entrypoint.sh "$@" 2>&1 |
while read -r line; do
  case "$line" in
    *'New connection from 127.0.0.1:'*' on port '"$HEALTHCHECK_PORT"'.') ;; # drop
    *'New client connected from 127.0.0.1:'*' as healthcheck '?'p2, c1, k60'?'.') ;; # drop
    *'Client healthcheck disconnected.') ;; # drop
    *) echo "$line" ;; # forward
  esac
done
