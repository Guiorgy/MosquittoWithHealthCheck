#!/bin/ash
set -e

config_path='/mosquitto/config/mosquitto-with-healthcheck.conf'

# copy the base configuration
config=$(cat /mosquitto/config/mosquitto.conf)

# add a comment to the top of the configuration
config_top="# auto-generated
# edit /mosquitto/config/mosquitto.conf instead"

# don't modify the config if a username or password is set
if [ -z "$HEALTHCHECK_USERNAME" ] && [ -z "$HEALTHCHECK_PASSWORD" ]; then
  # make settings apply locally per-listener
  config_top="$config_top

per_listener_settings true"

  # add a healthcheck listener to the bottom of the configuration
  config_bottom="# listener used for health checks
listener $HEALTHCHECK_PORT 127.0.0.1
socket_domain ipv4
sys_interval 60
allow_anonymous true"
fi

# build the final modified config
config="$config_top

$config

$config_bottom"

# make the previously generated modified configuration writable
if [ -f "$config_path" ]; then
  chmod +w "$config_path"
fi

# save the modified configuration
echo "$config" > "$config_path"

# make the modified configuration read-only (write protected)
chmod -w "$config_path"

# run the base mosquitto entrypoint script and filter out healthcheck messages from its logs
/mosquitto-docker-entrypoint.sh "$@" 2>&1 |
while read -r line; do
  case "$line" in
    *'New connection from 127.0.0.1:'*' on port '"$HEALTHCHECK_PORT"'.') ;; # drop
    *'New client connected from 127.0.0.1:'*' as healthcheck '?'p2, c1, k60'?'.') ;; # drop
    *'New client connected from 127.0.0.1:'*' as healthcheck '?'p2, c1, k60, u'"'"*"'"?'.') ;; # drop
    *'Client healthcheck disconnected.') ;; # drop
    *) echo "$line" ;; # forward
  esac
done
