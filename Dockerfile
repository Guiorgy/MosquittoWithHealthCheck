# syntax=docker/dockerfile:1
# todo: remove the above, once the 'start-interval' flag is fully supported by the current release

ARG TAG=latest

From eclipse-mosquitto:$TAG

# rename the original entrypoint script
RUN mv docker-entrypoint.sh mosquitto-docker-entrypoint.sh

# copy the new entrypoint script
COPY docker-entrypoint.sh /

# copy the healthcheck script
COPY check-health.sh /bin/

# fix line endings in case we are on Windows
RUN sed -i -e 's/\r$//' /docker-entrypoint.sh /bin/check-health.sh

# change permissions of copied files
RUN chmod 554 /mosquitto-docker-entrypoint.sh \
    && chmod 554 /docker-entrypoint.sh \
    && chmod 554 /bin/check-health.sh

# set the default healthcheck port, username, password and topic
ENV HEALTHCHECK_PORT="1880" \
    HEALTHCHECK_USERNAME="" \
    HEALTHCHECK_PASSWORD="" \
    HEALTHCHECK_TOPIC="\$SYS/broker/uptime"

# define the healthcheck tests parameters
HEALTHCHECK --start-period=20s --start-interval=2s --interval=10s --timeout=3s --retries=2 CMD /bin/check-health.sh

# run mosquitto with the modified configuration
CMD ["/usr/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto-with-healthcheck.conf"]
